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
  
  has_many :group_loan_weekly_tasks # weekly payment, weekly attendance  
  validates_presence_of   :name,
                          :number_of_meetings
                          
  validates_uniqueness_of :name 
  
  
  def self.create_object(  params)
    new_object = self.new
    
    new_object.name                            = params[:name] 
    new_object.number_of_meetings = params[:number_of_meetings]
    
    new_object.save
    
    return new_object 
  end
  
  def  update_object( params ) 
    return nil if self.is_started?  
      
    self.name                            = params[:name] 
    self.number_of_meetings = params[:number_of_meetings]
    
    self.save
    
    return self
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
    (1..self.number_of_collections).each do |week_number|
      GroupLoanWeeklyCollection.create :group_loan_id => self.id, :week_number => week_number
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
      errors.add(:generic_errors, "Pinjaman keuangan sudah di finalisasi")
      return self
    end
    
    if params[:disbursed_at].nil? or not params[:disbursed_at].is_a?(DateTime)
      errors.add(:disbursed_at, "Harus ada tanggal pemberian pinjaman")
      return self
    end
    
    self.disbursed_at = params[:disbursed_at]
    self.is_loan_disbursed = true 
    self.save 
    
    
    self.execute_loan_disbursement_payment 
    
    
    self.schedule_group_loan_weekly_collection 
    # self.create_group_loan_default_payments

    # create GroupLoanWeeklyCollection  => it has many weird cases. new problem domain on that model.
  end
  
  
=begin
  WeeklyCollection 
=end

  def loan_duration
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

  def total_compulsory_savings 
    self.glm_eligible_for_compulsory_savings_calculation.sum("total_compulsory_savings")
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
  
  
  def deduct_compulsory_savings_for_unsettled_default
    # if the member's compulsory savings is not sufficient, calculate that as office's bad debt expense 
    # return if self.active_group_loan_memberships.count == 0
    # 
    #   
    # 
    # self.active_group_loan_memberships.joins(:group_loan_default_payment).each do |glm|
    #   glm.group_loan_default_payment.execute_compulsory_savings_deduction 
    # end
    
    # create JournalPosting
    #  compulsory_savings is debit by the default_amount
    #  allowance is credited by the default_amount  (Allowance is contra account of revenue)
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
  
  def update_default_amount( amount ) 
    self.default_amount += amount
    self.save 
  end
  
  def update_default_payment_amount_receivable  
    # update the sum in the group_loan 
    
        # 
        # # update the default_payment#amount_receivable on 
        # # 1. weekly_payment_collection#confirm  => effect from run away and uncollectible will take place 
        # # 2. PrematureClearance#confirm  => should this be ported to be done inside weekly_payment_collection? 
        # # 3. GroupLoanAdditionalDefaultPayment#confirm  => this is right. 
        #   
        # total_amount = self.default_payment_total_amount
        #  
        # amount_to_be_deducted  = BigDecimal('0')
        # 
        # # we don't need to think whether member can pay for it.. just show the amount to be paid. 
        # # to pay or not to pay is another matter. 
        # # if self.total_compulsory_savings < total_amount 
        # #   amount_to_be_deducted = self.total_compulsory_savings
        # # else # case total_compulsory_savings => total_amount 
        # #   amount_to_be_deducted = total_amount
        # # end
        # 
        # amount_to_be_deducted = total_amount
        # 
        # total_active_glm = self.active_group_loan_memberships.count 
        # 
        # return if total_active_glm == 0 
        # 
        # splitted_amount = amount_to_be_deducted/total_active_glm 
        # 
        # self.active_group_loan_memberships.joins(:group_loan_default_payment).each do |glm| 
        #     
        #     default_payment = glm.group_loan_default_payment 
        #     default_payment.amount_receivable = self.class.rounding_up(splitted_amount, DEFAULT_PAYMENT_ROUND_UP_VALUE)
        #     default_payment.save 
        # end
  end
  
  def port_compulsory_savings_to_voluntary_savings
    self.active_group_loan_memberships.each do |glm|
      GroupLoanPortCompulsorySavings.create :group_loan_id => self.id, 
                                  :group_loan_membership_id => glm.id ,
                                  :member_id => glm.member_id ,
                                  :case =>PORT_GROUP_LOAN_COMPULSORY_SAVINGS_CASE[:group_loan_closing]
    end
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
  end
  
  def total_compulsory_savings_post_closure
    amount = total_compulsory_savings_pre_closure - default_amount
    if amount > BigDecimal('0')
      return amount
    else
      return BigDecimal('0')
    end
  end
 
  def close(params)
    if self.group_loan_weekly_collections.where(:is_confirmed => true, :is_collected => true).count != self.number_of_collections
      self.errors.add(:generic_errors, "Ada Pengumpulan mingguan yang belum selesai")
      return self 
    end
    
    if self.group_loan_weekly_uncollectibles.where(:is_cleared => false).count != 0 
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
    
     
    
    self.is_closed = true 
    self.save
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
    self.save 
  end

 
 
end