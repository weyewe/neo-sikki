require 'csv'

class GroupLoan < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :office 
  has_many :members, :through => :group_loan_memberships 
  has_many :group_loan_memberships 
  has_many :group_loan_weekly_collections 
  has_many :group_loan_weekly_uncollectibles 
  
  has_many :group_loan_run_away_receivables
  has_many :group_loan_run_away_receivable_payments 
  
  has_many :group_loan_disbursements 
  has_many :group_loan_port_compulsory_savings 
  
  has_many :savings_entries, :as => :financial_product 
  
  # has_many :group_loan_default_payments
  
  has_many :group_loan_premature_clearance_payments
  has_many :deceased_clearances 
  
  has_many :group_loan_weekly_tasks # weekly payment, weekly attendance  
  validates_presence_of   :name,
                          :number_of_meetings
                          
  validates_uniqueness_of :name 
  
  def id_number_name
    "#{self.name}"
  end
  
  def self.create_object(  params)
    new_object = self.new
    
    new_object.name                            = params[:name] 
    new_object.number_of_meetings = params[:number_of_meetings]
    new_object.group_number = params[:group_number]
    
    new_object.save
    
    return new_object 
  end
  
  def  update_object( params ) 
    if self.is_started?  
      self.errors.add(:generic_errors, "Sudah dimulai, tidak boleh update")
      return self 
    end
      
    self.name                            = params[:name] 
    self.number_of_meetings       = params[:number_of_meetings]
    # puts "3321 The group_number : #{params[:group_number]}\n"*100
    self.group_number             = params[:group_number]
    self.save
    
    # puts "5521 The error: #{self.errors.size}"
    
    return self
  end
  
  def delete_object
    if self.is_started? or self.group_loan_memberships.count != 0
      self.errors.add(:generic_errors, "Sudah ada keanggotaan pinjaman group")
      return self 
    end
    
    self.destroy 
  end
  
  
  def has_membership?( group_loan_membership)
    active_glm_id_list = self.active_group_loan_memberships.map {|x| x.id }
    
    active_glm_id_list.include?( group_loan_membership.id )
  end
  
  def set_group_leader( group_loan_membership ) 
    self.errors.add(:group_leader_id, "Harap pilih anggota dari group ini") if group_loan_membership.nil? 
    
     
    if self.has_membership?( group_loan_membership )  
      self.group_leader_id = group_loan_membership.id 
      self.save 
    else
      self.errors.add(:group_leader_id, "Bukan anggota dari pinjaman group ini")
    end
  end
  
  def active_group_loan_memberships
    if not self.is_closed?
      return self.group_loan_memberships.where(:is_active => true )
    else
      # GROUP_LOAN_DEACTIVATION_CASE
      return self.group_loan_memberships.where{
        (is_active.eq false ) & 
        ( deactivation_case.eq GROUP_LOAN_DEACTIVATION_CASE[:finished_group_loan] )
      }
    end 
  end
   
   
  def all_group_loan_memberships_have_equal_duration?
    duration_array = [] 
    self.active_group_loan_memberships.each do |glm|
      return false if glm.group_loan_product.nil?
      duration_array << glm.group_loan_product.total_weeks 
    end
    
    return false if duration_array.uniq.length != 1
    return true 
  end
  
=begin
  Encode the group loan phases
=end

  def is_financial_education_phase?
    is_started? and 
    not is_financial_education_finalized? and
    not is_loan_disbursement_finalized? and 
    not is_weekly_payment_period_closed? and 
    not is_grace_period_payment_closed?  and 
    not is_default_payment_period_closed? and 
    not is_closed? 
  end
  
  def is_loan_disbursement_phase? 
    is_started? and  
    not is_closed?
  end
  
  def is_weekly_payment_period_phase?
    is_started? and 
    is_financial_education_finalized? and
    is_loan_disbursement_finalized? and 
    not is_weekly_payment_period_closed? and 
    not is_grace_period_payment_closed? and 
    not is_default_payment_period_closed? and 
    not is_closed?
  end
  
  def is_grace_payment_period_phase?
    is_started? and 
    is_financial_education_finalized? and
    is_loan_disbursement_finalized? and 
    is_weekly_payment_period_closed? and 
    not is_grace_period_payment_closed? and 
    not is_default_payment_period_closed? and 
    not is_closed?
  end
  
  def is_default_payment_resolution_phase?
    is_started? and 
    is_financial_education_finalized? and
    is_loan_disbursement_finalized? and 
    is_weekly_payment_period_closed? and 
    is_grace_period_payment_closed? and 
    not is_default_payment_period_closed? and 
    not is_closed? 
  end
  
  def is_closing_phase?
    is_started? and 
    is_financial_education_finalized? and
    is_loan_disbursement_finalized? and 
    is_weekly_payment_period_closed? and 
    is_grace_period_payment_closed? and 
    is_default_payment_period_closed? and 
    not is_closed? 
  end
   
   
=begin
  Switching phases 
=end
  def start(params)
     
    if  self.is_started?
      errors.add(:generic_errors, "Pinjaman grup sudah dimulai")
      return self 
    end
    
    
    
    if self.group_loan_memberships.count == 0 
      errors.add(:generic_errors, "Jumlah anggota harus lebih besar dari 0")
      return self 
    end
    
    if not self.all_group_loan_memberships_have_equal_duration?
      errors.add(:generic_errors, "Durasi pinjaman harus sama")
      return self 
    end
    
    
    if params[:started_at].nil? or not params[:started_at].is_a?(DateTime)
      self.errors.add(:started_at, "Harus ada tanggal mulai")
      return self 
    end
    
    self.started_at = params[:started_at]
    self.is_started = true
    self.number_of_collections = self.loan_duration 
    self.save 
   
  end 
  
=begin
Phase: loan disbursement finalization
=end
 
   
  def execute_loan_disbursement_payment
    self.active_group_loan_memberships.each do |glm|
      GroupLoanDisbursement.create :group_loan_membership_id => glm.id , :group_loan_id => self.id 
    end
  end
  
  def schedule_group_loan_weekly_collection
    disbursed_date = self.disbursed_at
    (1..self.number_of_collections).each do |week_number|
      GroupLoanWeeklyCollection.create :group_loan_id => self.id, :week_number => week_number,
      :tentative_collection_date => disbursed_date + week_number.weeks 
    end
  end
  
  def create_group_loan_default_payments
    self.active_group_loan_memberships.each do |glm|
      GroupLoanDefaultPayment.create :group_loan_membership_id => glm.id ,
                                      :group_loan_id => self.id 
    end
  end

  def disburse_loan(params)
    
    if not self.is_loan_disbursement_phase?  
      errors.add(:generic_errors, "Bukan di fase penyerahan pinjaman")
      return self
    end
    
    if self.is_loan_disbursed?
      errors.add(:generic_errors, "Pinjaman sudah dicairkan")
      return self
    end
    
    if params[:disbursed_at].nil? or not params[:disbursed_at].is_a?(DateTime)
      errors.add(:disbursed_at, "Harus ada tanggal pemberian pinjaman")
      return self
    end
    
    begin
      ActiveRecord::Base.transaction do 
        
        self.disbursed_at = params[:disbursed_at]
        self.is_loan_disbursed = true
        self.save 

        self.execute_loan_disbursement_payment 
        self.schedule_group_loan_weekly_collection 
        self.execute_loan_disbursement_ledger_posting
        
      end
    rescue ActiveRecord::ActiveRecordError  
    else
    end
    
    
    
    
  end
  
  
=begin
  Debit: 1-141	Piutang Pinjaman Sejahtera
          1-111	Kas besar  (admin revenue) 
          
  Credit: 1-111	Kas besar  (money disbursed)
         4-111	Pendapatan administrasi pinjaman Sejahtera  (admin fee revenue)   
=end
  def execute_loan_disbursement_ledger_posting
    ta = TransactionData.create_object({
      :transaction_datetime => self.disbursed_at,
      :description => "Loan Disbursement: Group #{self.name}, #{self.group_number}" ,
      :transaction_source_id => self.id , 
      :transaction_source_type => self.class.to_s ,
      :code => TRANSACTION_DATA_CODE[:loan_disbursement],
      :is_contra_transaction => false 
    }, true )
    
    TransactionDataDetail.create_object(
      :transaction_data_id => ta.id,        
      :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_ar_leaf][:code]).id      ,
      :entry_case          => NORMAL_BALANCE[:debit]     ,
      :amount              => self.start_fund,
      :description => "Piutang Pinjaman Sejahtera dari Group #{self.name}, #{self.group_number} "
    )
    
    TransactionDataDetail.create_object(
      :transaction_data_id => ta.id,        
      :account_id          => Account.find_by_code(ACCOUNT_CODE[:main_cash_leaf][:code]).id        ,
      :entry_case          => NORMAL_BALANCE[:debit]     ,
      :amount              => self.admin_fee_revenue,
      :description => "Pendapatan admin fee dari Group #{self.name}, #{self.group_number} "
    )
    
    TransactionDataDetail.create_object(
      :transaction_data_id => ta.id,        
      :account_id          => Account.find_by_code(ACCOUNT_CODE[:main_cash_leaf][:code]).id      ,
      :entry_case          => NORMAL_BALANCE[:credit]     ,
      :amount              => self.start_fund,
      :description => "Penggunaan cash untuk loan disbursement dari Group #{self.name}, #{self.group_number} "
    )
    
    TransactionDataDetail.create_object(
      :transaction_data_id => ta.id,        
      :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_administration_revenue_leaf][:code]).id        ,
      :entry_case          => NORMAL_BALANCE[:credit]     ,
      :amount              => self.admin_fee_revenue,
      :description => "Pendapatan admin fee dari Group #{self.name}, #{self.group_number} "
    )
    
    
    ta.confirm
    
  end
  
  def can_be_undisbursed?
    if not self.is_loan_disbursed? 
      self.errors.add(:generic_errors, "Belum di disburse")
      return false 
    end
    
    
    # puts "inside the can_be_undisbursed?"
    
    first_glwc = self.group_loan_weekly_collections.where(:week_number => 1 ).first 
   
    if first_glwc.is_collected?
      # puts "first glwc is collected"
      self.errors.add(:generic_errors, "Sudah ada pengumpulan yang terkumpul")
      return false 
    end
    
    if group_loan_memberships.where(
                :is_active => false, 
                :deactivation_case => GROUP_LOAN_DEACTIVATION_CASE[:deceased],
                :deactivation_week_number => 1   ).count != 0 
                
      self.errors.add(:generic_errors, "Sudah ada member yang meninggal di pengumpulan ini")
      return false
    end
    
    if first_glwc.group_loan_run_away_receivables.count != 0
      self.errors.add(:generic_errors, "Sudah ada member yang kabur di pengumpulan ini")
      return false
    end
    
    if first_glwc.group_loan_weekly_uncollectibles.count != 0
      self.errors.add(:generic_errors, "Sudah ada member yang di declare tidak membayar di pengumpulan ini")
      return false
    end
    
    if first_glwc.group_loan_premature_clearance_payments.count != 0 
      self.errors.add(:generic_errors, "Sudah ada member yang premature clearance di pengumpulan ini")
      return false
    end
    
    if first_glwc.group_loan_weekly_collection_voluntary_savings_entries.count != 0 
      self.errors.add(:generic_errors, "Sudah ada member yang  membayar tabungan sukarela di pengumpulan ini")
      return false
    end
   
    return true
  end
  
  def undisburse 
    if not self.can_be_undisbursed?
      return self
    end
    
    # destroy all weekly collection
    self.group_loan_weekly_collections.each do |x|
      x.destroy 
    end
    
    # cancel loan disbursement execution 
    GroupLoanDisbursement.where(:group_loan_id => self.id ).each do |x|
      x.delete_object 
    end 
    
    self.is_loan_disbursed = false
    self.disbursed_at = nil
    if self.save 
      self.execute_loan_disbursement_contra_ledger_posting
    end
  end
  
  def execute_loan_disbursement_contra_ledger_posting
    last_transaction_data = TransactionData.where(
      :transaction_source_id => self.id , 
      :transaction_source_type => self.class.to_s ,
      :code => TRANSACTION_DATA_CODE[:loan_disbursement],
      :is_contra_transaction => false
    ).order("id DESC").first 
    
    last_transaction_data.create_contra_and_confirm if not last_transaction_data.nil?
  end
  
  def can_be_canceled?
    if self.is_loan_disbursed?
      self.errors.add(:generic_errors, "Sudah ada disbursement")
      return false 
    end
    
        
  
    return true 
  end
  
  def cancel_start
    if not self.can_be_canceled?
      return self 
    end
    
    self.group_loan_memberships.where(
          :is_active => false,
          :deactivation_case => [
              GROUP_LOAN_DEACTIVATION_CASE[:financial_education_absent],
              GROUP_LOAN_DEACTIVATION_CASE[:loan_disbursement_absent]
            ]
    ).each do |glm|
      glm.is_active = true 
      glm.deactivation_case = nil
      glm.save 
    end
    
    self.started_at =  nil 
    self.is_started = false 
    self.number_of_collections = 0 
    self.save
  end
  
  
=begin
  WeeklyCollection 
=end

  def loan_duration
    return 0 if not self.is_started?
    duration_array = []
    self.active_group_loan_memberships.each do |glm|
      duration_array << glm.group_loan_product.total_weeks
    end
    
    return duration_array.uniq.first  
  end
  
  def has_unconfirmed_weekly_collection?
    self.group_loan_weekly_collections.where(:is_confirmed => false, :is_collected => true).count != 0 
  end
  
  def first_uncollected_weekly_collection
    self.group_loan_weekly_collections.where(:is_confirmed => false, :is_collected => false).order("id ASC").first 
  end
  
=begin
  WeeklyCollection Finish 
=end

  def glm_eligible_for_compulsory_savings_calculation
    if not self.is_closed?
      return self.group_loan_memberships.where{
        (is_active.eq true) | 
        (
          (is_active.eq false) &
          (deactivation_case.eq GROUP_LOAN_DEACTIVATION_CASE[:run_away])
        )
      }
    else
      # GROUP_LOAN_DEACTIVATION_CASE
      return self.group_loan_memberships.where{
        (is_active.eq false ) & 
        (
          (deactivation_case.eq GROUP_LOAN_DEACTIVATION_CASE[:finished_group_loan] ) | 
          (deactivation_case.eq GROUP_LOAN_DEACTIVATION_CASE[:run_away])
        )
        
      }
    end
  end

  # def total_compulsory_savings 
  #   self.glm_eligible_for_compulsory_savings_calculation.sum("total_compulsory_savings")
  # end
  
  def total_compulsory_savings
    self.group_loan_memberships.sum("total_compulsory_savings")
  end



  def self.rounding_up(amount,  nearest_amount ) 
    total = amount
    # total_amount

    multiplication_of_500 = ( total.to_i/nearest_amount.to_i ) .to_i
    remnant = (total.to_i%nearest_amount.to_i)
    if remnant > 0  
      return  nearest_amount *( multiplication_of_500 + 1 )
    else
      return nearest_amount *( multiplication_of_500  )
    end  
  end
  
  def self.rounding_down(amount, nearest_amount)
    total = amount
    # total_amount

    multiplication_of_500 = ( total.to_i/nearest_amount.to_i ) .to_i
    return nearest_amount *( multiplication_of_500  ) 
  end
  
  
  
  def deduct_compulsory_savings_for_unsettled_default
  #   default that is deducted from the total compusory savings 
  # hence, the amount of money returned is pre
  
  # self.compulsory_savings_deduction_amount = 
  
  # 1. get the total default amount deductible from compulsory savings 
  # 2. save the amount to compulsory_savings_deduction_amount
  # 3. perform journal posting. 

=begin
  uang_titipan = premature_clearance_deposit 

  case 1: 
    compulsory_savings + uang_titipan > principal + interest of the run away member 
  case 2:
    principal < compulsory_savings + uang_titipan < principal + interest of the run away member 
  case 3:
    principal > compulsory_savings + uang_titipan 
=end
    
  end
  
  def cleared_default_payment_amount
    # puts " #group_loan.cleared_default_payment_amount: We have not been implemented.\n"
    # sum of default payment made by premature payment 
    sum = BigDecimal('0')
    
    self.group_loan_memberships.where(
      :is_active => false, 
      :deactivation_case => GROUP_LOAN_DEACTIVATION_CASE[:premature_clearance]
      ).each do |glm|
        sum += glm.group_loan_default_payment.amount_receivable 
    end
    return sum #  BigDecimal('0')
  end
  
  # def default_payment_total_amount  # we will redo this method
  #   total_amount = BigDecimal('0')
  #   # The defaults: 
  #   # 1. + run_away_receivable (payment_case => end_of_cycle ) 
  #   # 2. + uncollected weekly payment 
  #   # 3. - deduct by the total amount of GroupLoanAdditionalDefaultPayment  (can come from member.. but doesn't matter)
  #   # 4. - Deduct by the total amount of PrematureClearance 
  #   
  #   # on deceased member, if they have default, will be handled by the present member 
  #   # recalculate the default resolution amount. 
  #   
  #   # total debt: sum of all default_payment.remaining_amount_receivable where the glm.is_active => true 
  #   
  #   
  #   #### HANDLING THE DEFAULTS 1: run_away_receivable 
  #   # cases: 
  #   # 0. no run_away_receivable
  #   # 1. only one run_away_receivable
  #   # 2. many run_away_receivable 
  #   
  #   total_amount += self.group_loan_run_away_receivables.
  #       where(:payment_case => GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:end_of_cycle]).
  #       sum('amount_receivable')
  #       
  #   # contribution from the uncollectibles
  #   total_amount += self.group_loan_weekly_uncollectibles.sum("amount")
  #   
  #   # total_amount -= self.cleared_default_payment_amount # from member premature clearce
  #   
  #   if total_amount < BigDecimal('0')
  #     return BigDecimal('0')
  #   else
  #     return total_amount
  #   end
  #   
  # end
  
  
  # default payment amount_receivable will be updated on:
  #  1. run_away member 
  #   2. uncollectible weekly collection 
  
  
  # glm.group_loan_default_payment.amount_receivable => total split must be paid 
  # glm.group_loan_default_payment.amount_received == payment 
  
  # def update_default_amount( amount ) 
  #   self.default_amount += amount
  #   self.save 
  # end
  

  def update_bad_debt_allowance( amount ) 
    self.bad_debt_allowance += amount 
    self.save 
  end
  
  
  
   
  def deactivate_group_loan_memberships_due_to_group_closed
    self.active_group_loan_memberships.each do |glm|
      glm.is_active = false 
      glm.deactivation_case = GROUP_LOAN_DEACTIVATION_CASE[:finished_group_loan]
      glm.save 
    end
  end
  
  
  def manifest_total_compulsory_savings_pre_closure
    self.total_compulsory_savings_pre_closure = self.total_compulsory_savings
    self.save 
    
    self.group_loan_memberships.each do |glm|
      SavingsEntry.create_group_loan_closing_compulsory_savings_clearance( glm )
    end
  end
  
  def total_compulsory_savings_post_closure
    amount = total_compulsory_savings_pre_closure - default_amount
    if amount > BigDecimal('0')
      return amount
    else
      return BigDecimal('0')
    end
  end
  
  def clear_end_of_cycle_uncollectibles
    self.group_loan_weekly_uncollectibles.where(
      :clearance_case => UNCOLLECTIBLE_CLEARANCE_CASE[:end_of_cycle],
      :is_cleared => false 
    ).each { |x| x.clear_end_of_cycle}
  end
 
  def close(params)
    if self.group_loan_weekly_collections.where(:is_confirmed => true, :is_collected => true).count != self.number_of_collections
      self.errors.add(:generic_errors, "Ada Pengumpulan mingguan yang belum selesai")
      return self 
    end
    
    if self.group_loan_weekly_uncollectibles.where(
          :is_cleared => false, 
          :clearance_case => UNCOLLECTIBLE_CLEARANCE_CASE[:in_cycle] ).count != 0 
      self.errors.add(:generic_errors, "Ada pembayaran tak tertagih")
      return self 
    end
    
    
    if self.is_closed?
      self.errors.add(:generic_errors, "Sudah ditutup")
      return self 
    end
    
    if params[:closed_at].nil? or not params[:closed_at].is_a?(DateTime)
      self.errors.add(:closed_at, "Harus ada tanggal tutup")
      return self 
    end
    
    self.closed_at = params[:closed_at]
    
    if self.closed_at.nil?
      self.errors.add(:closed_at, "Harus ada tanggal penutupan")
      return self 
    end
    
    
    
    # perform deduction for those unpaid member
    self.manifest_total_compulsory_savings_pre_closure
    self.deduct_compulsory_savings_for_unsettled_default 
    self.deactivate_group_loan_memberships_due_to_group_closed
    
    # clear the group_loan_compulsory_savings
    
    
    # self.update_bad_debt_allowance
    # self.update_bad_debt_expense 
    
    self.is_closed = true 
    
    if self.save
      puts "going to clear uncollectibles from group_loan"
      self.clear_end_of_cycle_uncollectibles
    else
      puts "fail to save group loan"
      self.errors.messages.each {|x| puts "err close: #{x}"}
    end
    
    
    
    # create journal posting to recover bad_debt_allowance
    # create journal posting to assume bad_debt_expense 
  end
  
  def expected_revenue_from_run_away_member_end_of_cycle_resolution
    if loan_duration.nil?
      return BigDecimal("0")
    end
    
    total_week = self.loan_duration
    amount = BigDecimal('0')
    
    run_away_end_of_cycle_resolution_receivables = self.group_loan_run_away_receivables.joins(
                        :group_loan_membership => [:group_loan_product]
                      ).
                      where(:payment_case => GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:end_of_cycle])
    
    return amount if run_away_end_of_cycle_resolution_receivables.count == 0
    
    run_away_end_of_cycle_resolution_receivables.each do |x|
      run_away_week = x.group_loan_weekly_collection.week_number 
      remaining_week = total_week - run_away_week + 1 
      amount += x.group_loan_membership.group_loan_product.interest  * remaining_week
    end
    
    return amount 
  end
  
  def compulsory_savings_return_amount
    return BigDecimal('0') if not self.is_closed?
    
    amount =   self.total_compulsory_savings  + 
              self.premature_clearance_deposit  -
              self.bad_debt_allowance - # uncleared uncollectibles, run_away end_of_cycle resolution 
              self.expected_revenue_from_run_away_member_end_of_cycle_resolution
              
    return BigDecimal('0') if amount <= BigDecimal('0')
    
    return amount 
  end
  
  
  
  
  def withdraw_compulsory_savings(params)
    
    # puts "withdraw_compulsory_savings is called"
    if not self.is_closed?
      self.errors.add(:generic_errors, "Belum ditutup")
      # puts "adding error.. returning myself"
      return self 
    end
    
    
    
    
    if params[:compulsory_savings_withdrawn_at].nil? or not params[:compulsory_savings_withdrawn_at].is_a?(DateTime)
      self.errors.add(:compulsory_savings_withdrawn_at, "Harus ada tanggal penarikan sisa tabungan wajib")
      return self 
    end
    
    self.compulsory_savings_withdrawn_at = params[:compulsory_savings_withdrawn_at]
    self.is_compulsory_savings_withdrawn = true
   
    self.round_down_compulsory_savings_return_revenue = self.compulsory_savings_return_amount -  
                GroupLoan.rounding_down(  
                            self.compulsory_savings_return_amount,
                            DEFAULT_PAYMENT_ROUND_UP_VALUE
                )
                
    self.save 
    
    # create the journal posting.
    # 1. to record deduction of amount_payable
    # 2. to record extra revenue from rounding_down
  end
  
  
=begin
  Start Group Loan
=end
  

  def total_members_count
    self.group_loan_memberships.count 
  end
  
  def start_fund
    amount = BigDecimal("0")
    self.group_loan_memberships.joins(:group_loan_product).each do |glm|
      # amount += glm.group_loan_product.weekly_payment_amount * glm.group_loan_product.total_weeks
      amount += glm.group_loan_product.actual_amount_to_be_disbursed
    end
    
    return amount 
  end
  
  def admin_fee_revenue
    amount = BigDecimal("0")
    self.group_loan_memberships.joins(:group_loan_product).each do |glm|
      # amount += glm.group_loan_product.weekly_payment_amount * glm.group_loan_product.total_weeks
      amount += glm.group_loan_product.admin_fee
    end
    
    return amount
  end

=begin
  Disburse Group Loan
=end 

  def non_disbursed_fund
    # return BigDecimal("0") if not self.is_loan_disbursed?
    start_fund - disbursed_fund 
  end
  
  def disbursed_group_loan_memberships
     
    if self.is_closed?
      return self.group_loan_memberships.where(:deactivation_case => [
          GROUP_LOAN_DEACTIVATION_CASE[:finished_group_loan],
          GROUP_LOAN_DEACTIVATION_CASE[:deceased],
          GROUP_LOAN_DEACTIVATION_CASE[:run_away],
          GROUP_LOAN_DEACTIVATION_CASE[:premature_clearance]
        ]) 
    else
      return self.group_loan_memberships.where{
        (is_active.eq true) | 
        (
          (is_active.eq false) & 
          (deactivation_case.in [
              GROUP_LOAN_DEACTIVATION_CASE[:deceased],
              GROUP_LOAN_DEACTIVATION_CASE[:run_away],
              GROUP_LOAN_DEACTIVATION_CASE[:premature_clearance]
            ])
        )
      } 
    end
  end
  
  def disbursed_group_loan_memberships_count
    return 0 if not self.is_loan_disbursed? 
    
    disbursed_group_loan_memberships.count 
  end
  
  
  # disbursed_fund vs non_disbursed_fund 
  def disbursed_fund
    amount = BigDecimal('0')
    # return amount if not self.is_loan_disbursed? 
    
    disbursed_group_loan_memberships.joins(:group_loan_product).each do |glm|
      amount += glm.group_loan_product.principal * glm.group_loan_product.total_weeks
    end
    return amount 
  end
  
  def update_premature_clearance_deposit(amount)
    self.premature_clearance_deposit += amount
    self.save 
  end
  

  
  def self.to_csv
    column_names = [
        "Group No",
        "Nama Kelompok",
        "Jumlah Anggota Aktif",
        "Jumlah Minggu Setoran",
        "Jumlah Minggu Terbayar",
        "Last Payment Date",
        "Jumlah Setoran Berikutnya"
      ]
    
    
    CSV.generate do |csv|
      csv << column_names
      all.each do |group_loan|
        
        last_collected = group_loan.group_loan_weekly_collections.where(:is_collected => true, :is_confirmed => true ).order("id ASC").last
        
        collected_at = nil
        collected_at = last_collected.collected_at if not last_collected.nil?
        
        next_collection_amount = BigDecimal("0")
        next_collection = group_loan.group_loan_weekly_collections.where(:is_collected => false, :is_confirmed => false ).order("id ASC").first
        
        next_collection_amount = next_collection.amount_receivable if not next_collection.nil? 
        
        result = [
            group_loan.group_number,
            group_loan.name, 
            group_loan.active_group_loan_memberships.count , 
            group_loan.number_of_collections,
            group_loan.group_loan_weekly_collections.where(:is_collected => true, :is_confirmed => true ).count ,
            collected_at,
            next_collection_amount
          ]
        csv <<  result 
      end
    end
  end
  
=begin
  Close GroupLoan
=end
  # return the active_group_loan_memberships.count (always changing weekly) 
  
  
  
  
  
  
  # bad_debt_allowance should be updated on uncollectible creation, uncollectible clearance,
  # and on the run_away end_of_cycle resolution 
  
  # it should be updated on group loan close: we use member's compulsory savings to cover for bad debt
  # if there is still bad debt: mark it as expense 
  
  
  
 
 
end

=begin
GroupLoan.where(:is_loan_disbursed => true ).each do |group_loan|
  disbursed_date = group_loan.disbursed_at 
  group_loan.group_loan_weekly_collections.each do |glwc|
    glwc.tentative_collection_date = disbursed_date  + glwc.week_number.weeks
    glwc.save 
  end
end
=end