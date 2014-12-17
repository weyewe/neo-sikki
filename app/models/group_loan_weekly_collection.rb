class GroupLoanWeeklyCollection < ActiveRecord::Base
  attr_accessible :group_loan_id, :week_number , :tentative_collection_date 
  belongs_to :group_loan 
  validates_presence_of :group_loan_id, :week_number 
  
  has_many :group_loan_run_away_receivables 
  has_many :group_loan_weekly_uncollectibles
  has_many :group_loan_premature_clearance_payments 
  has_many :group_loan_weekly_payments
  has_many :group_loan_weekly_collection_voluntary_savings_entries
  
  
  def first_non_collected?
    group_loan.group_loan_weekly_collection.where(
      :is_collected => false 
    )
  end
  
  def collect(params)
    if self.is_collected?
      self.errors.add(:generic_errors, "Sudah melakukan pengumpulan untuk minggu #{self.week_number}")
      return self 
    end
    
    if self.group_loan.has_unconfirmed_weekly_collection?
      self.errors.add(:generic_errors, "Ada pembayaran mingguan yang belum di konfirmasi")
      return self
    end
    
    first_uncollected_weekly_collection = self.group_loan.first_uncollected_weekly_collection
    if  first_uncollected_weekly_collection and 
        self.id  != first_uncollected_weekly_collection.id 
      self.errors.add(:generic_errors, "Pembayaran di minggu #{first_uncollected_weekly_collection.week_number} belum dilakukan")
      return self
    end
    
    
    # self.premature_clearance_deposit_usage = BigDecimal( params[:premature_clearance_deposit_usage] ||  '0' )
    
    if params[:collected_at].nil? or not params[:collected_at].is_a?(DateTime)
      self.errors.add(:collected_at, "Harus ada tanggal penerimaan pembayaran")
      return self 
    end
    
    self.collected_at = params[:collected_at]
    self.is_collected = true  
    
    
    self.save 
  end
  
  def create_group_loan_weekly_payments
    # puts "inside weekly_collection: create_group_loan_weekly_payments"
    # do weekly payment for all active members
    # minus those that can't pay  (the dead and running away is considered as non active)    
    uncollectible_glm_id_list = self.uncollectible_group_loan_membership_id_list
    active_glm_id_list = self.active_group_loan_memberships.map {|x| x.id }
    run_away_glm_id_list = group_loan.
                          group_loan_memberships.joins(:group_loan_run_away_receivable).
                          where{
                            (deactivation_case.eq  GROUP_LOAN_DEACTIVATION_CASE[:run_away] ) & 
                            (group_loan_run_away_receivable.payment_case.eq GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly])
                          }.map{|x| x.id }
    active_glm_id_list = active_glm_id_list - uncollectible_glm_id_list
    run_away_glm_id_list = run_away_glm_id_list - uncollectible_glm_id_list
    
    active_glm_id_list.each do |glm_id|
      GroupLoanWeeklyPayment.create :group_loan_membership_id => glm_id,
                                    :group_loan_id => self.group_loan_id,
                                    :group_loan_weekly_collection_id => self.id ,
                                    :is_run_away_weekly_bailout => false 
    end
    
    
    run_away_glm_id_list.each do |glm_id|
      GroupLoanWeeklyPayment.create :group_loan_membership_id => glm_id,
                                    :group_loan_id => self.group_loan_id,
                                    :group_loan_weekly_collection_id => self.id ,
                                    :is_run_away_weekly_bailout => true
    end
    
    
    total_main_cash = BigDecimal("0")
    total_interest_revenue = BigDecimal("0")
    total_principal = BigDecimal("0")
    total_compulsory_savings = BigDecimal("0")
    
    # paying_member = (active_glm_id_list + run_away_glm_id_list).uniq - uncollectible_glm_id_list
    
    GroupLoanMembership.where(:id =>  active_glm_id_list + run_away_glm_id_list ).joins(:group_loan_product).each do |glm|
      total_interest_revenue +=   glm.group_loan_product.interest 
      total_principal +=         glm.group_loan_product.principal 
      total_compulsory_savings += glm.group_loan_product.compulsory_savings
    end
    
    
    message = "Weekly Collection: Group #{group_loan.name}, #{group_loan.group_number}, week #{self.week_number}"
    ta = TransactionData.create_object({
      :transaction_datetime => self.collected_at,
      :description =>  message,
      :transaction_source_id => self.id , 
      :transaction_source_type => self.class.to_s ,
      :code => TRANSACTION_DATA_CODE[:group_loan_weekly_collection_voluntary_savings],
      :is_contra_transaction => false 
    }, true )
    
     
    
    TransactionDataDetail.create_object(
      :transaction_data_id => ta.id,        
      :account_id          => Account.find_by_code(ACCOUNT_CODE[:main_cash_leaf][:code]).id      ,
      :entry_case          => NORMAL_BALANCE[:debit]     ,
      :amount              => total_compulsory_savings + total_principal +  total_interest_revenue,
      :description => message
    )
    
    TransactionDataDetail.create_object(
      :transaction_data_id => ta.id,        
      :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_interest_revenue_leaf][:code]).id        ,
      :entry_case          => NORMAL_BALANCE[:credit]     ,
      :amount              => total_interest_revenue,
      :description => message
    )
    TransactionDataDetail.create_object(
      :transaction_data_id => ta.id,        
      :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_ar_leaf][:code]).id        ,
      :entry_case          => NORMAL_BALANCE[:credit]     ,
      :amount              => total_principal,
      :description => message
    )
    TransactionDataDetail.create_object(
      :transaction_data_id => ta.id,        
      :account_id          => Account.find_by_code(ACCOUNT_CODE[:compulsory_savings_leaf][:code]).id        ,
      :entry_case          => NORMAL_BALANCE[:credit]     ,
      :amount              => total_compulsory_savings,
      :description => message
    )
    
    ta.confirm
    
    
    
    
    
    
  end
  
  
  
  
  
  def update_group_loan_bad_debt_allowance
    # ths will produce the final allowance
    group_loan.update_bad_debt_allowance(                 
                      self.extract_uncollectible_weekly_payment_default_amount + 
                      self.extract_run_away_end_of_cycle_resolution_default_amount
    )
    
  end
  
  def post_extra_revenue_from_rounding_up
    total_amount_receivable = self.total_amount.truncate(2)
    billed = GroupLoan.rounding_up( total_amount  , DEFAULT_PAYMENT_ROUND_UP_VALUE ) 
    
    diff = billed - total_amount_receivable
    
    
    # 7-118
    if diff != BigDecimal("0")
      message = "Pembulatan Nilai: Group #{group_loan.name}, #{group_loan.group_number}, week #{self.week_number}"
      ta = TransactionData.create_object({
        :transaction_datetime => self.collected_at,
        :description =>  message,
        :transaction_source_id => self.id , 
        :transaction_source_type => self.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_weekly_collection_round_up],
        :is_contra_transaction => false 
      }, true )



      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:main_cash_leaf][:code]).id      ,
        :entry_case          => NORMAL_BALANCE[:debit]     ,
        :amount              => diff,
        :description => message
      )

      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:other_revenue_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:credit]     ,
        :amount              => diff,
        :description => message
      )
      
      ta.confirm 
    end
     
  end
  
  def unpost_rounding_up_revenue
    ta = TransactionData.where({
      :transaction_source_id => self.id , 
      :transaction_source_type => self.class.to_s ,
      :code => TRANSACTION_DATA_CODE[:group_loan_weekly_collection_round_up],
      :is_contra_transaction => false 
    } ).order("id DESC").first 
    
    ta.create_contra_and_confirm if not  ta.nil?
  end
  
  
  
  def post_run_away_allowance_end_of_cycle_resolved
    total_allowance = BigDecimal("0")
    self.group_loan_run_away_receivables.
          where(:payment_case => GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:end_of_cycle]).each do |x|
           
      
      allowance_amount = x.group_loan_membership.group_loan_product.principal * self.remaining_weeks 
      
      
      message = "Penyisihan Member Kabur, diselesaikan di akhir siklus : Group #{group_loan.name}, #{group_loan.group_number}" + 
                  " , week #{self.week_number}" + 
                  " , member #{x.member.name}, #{x.member.id_number}"

      ta = TransactionData.create_object({
        :transaction_datetime => self.collected_at,
        :description =>  message,
        :transaction_source_id => x.id , 
        :transaction_source_type => x.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_run_away_end_of_cycle_clearance],
        :is_contra_transaction => false 
      }, true )



      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_bda_leaf][:code]).id      ,
        :entry_case          => NORMAL_BALANCE[:debit]     ,
        :amount              => allowance_amount,
        :description => message
      )

      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_ar_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:credit]     ,
        :amount              => allowance_amount,
        :description => message
      )

      ta.confirm 
    end
  end
  
  def post_deceased_allowance
    remaining_weeks = self.remaining_weeks 
    
    self.group_loan.group_loan_memberships.where(
      :is_active => false, 
      :deactivation_case => GROUP_LOAN_DEACTIVATION_CASE[:deceased],
      :deactivation_week_number => self.week_number
      ).each do |x|
      
      
        allowance_amount = x.group_loan_product.principal * remaining_weeks
        message = "Penyisihan Member Meninggal : Group #{group_loan.name}, #{group_loan.group_number}" + 
                    " , week #{self.week_number}" + 
                    " , member #{x.member.name}, #{x.member.id_number}"

        ta = TransactionData.create_object({
          :transaction_datetime => self.collected_at,
          :description =>  message,
          :transaction_source_id => x.id , 
          :transaction_source_type => x.class.to_s ,
          :code => TRANSACTION_DATA_CODE[:group_loan_deceased_allowance],
          :is_contra_transaction => false 
        }, true )



        TransactionDataDetail.create_object(
          :transaction_data_id => ta.id,        
          :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_bda_leaf][:code]).id      ,
          :entry_case          => NORMAL_BALANCE[:debit]     ,
          :amount              => allowance_amount,
          :description => message
        )

        TransactionDataDetail.create_object(
          :transaction_data_id => ta.id,        
          :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_ar_leaf][:code]).id        ,
          :entry_case          => NORMAL_BALANCE[:credit]     ,
          :amount              => allowance_amount,
          :description => message
        )

        ta.confirm
      
    end
  end
  
  
  def undo_post_run_away_allowance_end_of_cycle_resolved
    self.group_loan_run_away_receivables.
          where(:payment_case => GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:end_of_cycle]).each do |x|
           
      

      ta = TransactionData.create_object({
        :transaction_source_id => x.id , 
        :transaction_source_type => x.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_run_away_end_of_cycle_clearance],
        :is_contra_transaction => false 
      } ).order("id DESC").first 


      ta.create_contra_and_confirm if not ta.nil? 
    end
  end
  
  
  def undo_post_deceased_allowance
    
    self.group_loan.group_loan_memberships.where(
      :is_active => false, 
      :deactivation_case => GROUP_LOAN_DEACTIVATION_CASE[:deceased],
      :deactivation_week_number => self.week_number
      ).each do |x|
      
        ta = TransactionData.create_object({
          :transaction_source_id => x.id , 
          :transaction_source_type => x.class.to_s ,
          :code => TRANSACTION_DATA_CODE[:group_loan_deceased_allowance],
          :is_contra_transaction => false 
        } ).order("id DESC").first

        ta.create_contra_and_confirm if not ta.nil? 
      
    end
  end
  
  
  
  def confirm(params)
    if not self.is_collected?
      self.errors.add(:generic_errors, "Belum melakukan pengumpulan di minggu ini")
      return self 
    end
    
    if self.is_collected? and self.is_confirmed?
      self.errors.add(:generic_errors, "Sudah dikonfirmasi")
      return self 
    end
    
    
    if params[:confirmed_at].nil? or not params[:confirmed_at].is_a?(DateTime)
      self.errors.add(:confirmed_at, "Harus ada tanggal konfirmasi pembayaran")
      return self 
    end
    
    begin
      ActiveRecord::Base.transaction do
        # accounting posting for each voluntary_savings paid on weekly collection 
        self.group_loan_weekly_collection_voluntary_savings_entries.each do |x|
          x.confirm
        end
        self.confirmed_at = params[:confirmed_at]
        self.is_confirmed = true 
        self.save 

        # we create accounting posting as well: cash, account receivable, 
        # interest revenue and compulsory savings
        self.create_group_loan_weekly_payments 
        
        
        
        
        # need to create posting: bad debt allowance 
        # from uncollectible +  run_away_member
        self.update_group_loan_bad_debt_allowance  # in the run away, the posting is not being done here. 
        self.confirm_uncollectible_allowance # allowance.. there will be expense during loan close
        self.post_run_away_allowance_end_of_cycle_resolved
        self.post_deceased_allowance
        
        # we need to create posting: premature_clearance_deposit and premature_clearance money itself 
        self.confirm_premature_clearances # DONE , the undo is done..
        
        self.post_extra_revenue_from_rounding_up
        # for run away member, now by default it is in-cycle
        # can't be edited. there should be posting. but not for now. 
=begin
  Accounts used for group loan weekly collection: 
  1. 1-111	Kas besar
  2. 1-141	Piutang Pinjaman Sejahtera
  3. 4-121	Pendapatan bagi hasil pinjaman Sejahtera
  4. 2-111	Tabungan Wajib
  5. 2-112	Tabungan Pribadi
  Run Away, Deceased
  6. 7. 1-151	Penyisihan Piutang Tak Tertagih Pinjaman Sejahtera
  Premature Clearance
  8. 2-192	Uang titipan   [digunakan jika ada outstanding run_away member yang ditanggung bersama]
  Rounding up
  9. 7-118	Pembulatan nilai
  Compulsory Savings Inequality
  10. 6-211	Beban Penghapusan Piutang Pinjaman Sejahtera
=end      
      end
    rescue ActiveRecord::ActiveRecordError  
    else
    end
  end
   
  
  def next_weekly_collection
    current_week_number=  self.week_number
    return group_loan.group_loan_weekly_collections.where(:week_number => current_week_number + 1 ).first
  end
  
  def can_be_unconfirmed? 
    
    if not self.is_confirmed? 
      self.errors.add(:generic_errors, "Belum di konfirmasi")
      return false 
    end
    
    
    next_week_collection = self.next_weekly_collection
    
    
    if not next_week_collection.nil?
      next_week_week_number = next_week_collection.week_number
      if  next_week_collection.is_collected?
        # puts "next week collection is collected "
        self.errors.add(:generic_errors, "Pengumpulan minggu berikutnya sudah di konfirmasi.")
        # puts "Total error in the shite: #{self.errors.size}"
        return false
      else
         
        
        # in the next week: 
        # 1. check whether it has deceased 
        
        if group_loan.group_loan_memberships.where(
                    :is_active => false, 
                    :deactivation_case => GROUP_LOAN_DEACTIVATION_CASE[:deceased],
                    :deactivation_week_number => next_week_week_number   ).count != 0 
                    
          self.errors.add(:generic_errors, "Sudah ada member yang meninggal di minggu #{next_week_week_number}")
          return false
        end
    
        # 2. check whether it has run_away
        if next_week_collection.group_loan_run_away_receivables.count != 0
          self.errors.add(:generic_errors, "Sudah ada member yang kabur di minggu #{next_week_week_number}")
          return false
        end
          
        # 3. check whether it has group_loan_weekly_uncollectibles
        if next_week_collection.group_loan_weekly_uncollectibles.count != 0
          self.errors.add(:generic_errors, "Sudah ada member yang di declare tidak membayar di minggu #{next_week_week_number}")
          return false
        end
        
        # 4. check whether it has premature_clearance
        if next_week_collection.group_loan_premature_clearance_payments.count != 0 
          self.errors.add(:generic_errors, "Sudah ada member yang premature clearance di minggu #{next_week_week_number}")
          return false
        end
        
        # 5. check whether it has weekly_collection_voluntary_savings
        if next_week_collection.group_loan_weekly_collection_voluntary_savings_entries.count != 0 
          self.errors.add(:generic_errors, "Sudah ada member yang  membayar tabungan sukarela di minggu #{next_week_week_number}")
          return false
        end
        
        
      end
    end
    
    # now, the case where the current week to be unconfirmed is the last week. hence, there is no next week
    if group_loan.is_closed? 
      self.errors.add(:generic_errors, "Group loan sudah ditutup")
      return false 
    end
    
    return true 
  end
  
  
  def uncreate_group_loan_weekly_payments
    GroupLoanWeeklyPayment.where(
      :group_loan_id => self.group_loan_id,
      :group_loan_weekly_collection_id => self.id ,
    ).each do |glwp|
      glwp.delete_object
    end
    
    # create contra posting 
  end
  
  def unconfirm_weekly_collection_voluntary_savings 
    self.group_loan_weekly_collection_voluntary_savings_entries.each do |x|
      x.unconfirm
      
    end
  end
  
  def unconfirm_premature_clearances
    self.group_loan_premature_clearance_payments.each do |x|
      x.unconfirm 
    end
  end
  
  def unconfirm
    # puts "3321 Unconfirm"
    if not self.can_be_unconfirmed?
      # puts "Total error in self: #{self.errors.size}"
      return self 
    end
    
    begin
      ActiveRecord::Base.transaction do
        
        #0. unconfirm summary on bad debt allowance in group loan 
        # puts "cancel the bad debt"
        group_loan.update_bad_debt_allowance(      
                          -1 * (
                            self.extract_uncollectible_weekly_payment_default_amount + 
                            self.extract_run_away_end_of_cycle_resolution_default_amount
                          )
        )
        group_loan.save
        
        
        #1.  unconfirm all voluntary savings 
        # puts "cancel the weekly collection voluntary savings"
        self.unconfirm_weekly_collection_voluntary_savings 
        
        # puts "gonna update is_confirmed to be false "
        self.confirmed_at = nil
        self.is_confirmed = false  
        self.save 
        
        
        
        #2.  unconfirm all compulsory savings 
        # puts "creating group loan weekly payments"
        self.uncreate_group_loan_weekly_payments   # ok  
        
        #3. unconfirm premature clearance
        # puts "unconfirm premature clearances"
        
        
        self.unpost_rounding_up_revenue 
        self.unconfirm_premature_clearances
        
        self.undo_post_run_away_allowance_end_of_cycle_resolved
        self.undo_post_deceased_allowance
        self.unconfirm_uncollectible_allowance
        
        # puts "all is good"
       
       # unconfirm uncollectible
        
      end
    rescue ActiveRecord::ActiveRecordError  
    else
    end 
  end
  
  
  
  def uncollect
    if self.is_confirmed?
      self.errors.add(:generic_errors, "Sudah di konfirmasi. Harap Unconfirm")
      return self 
    end
    
    if not self.is_collected? 
      self.errors.add(:generic_errors, "Belum ada Collection")
      return self 
    end
       
    self.collected_at = nil
    self.is_collected = false  
    self.save
  end
  

  
  def confirm_premature_clearances
    self.group_loan_premature_clearance_payments.each do |x|
      x.confirm 
    end
  end
 
 
  def confirm_uncollectible_allowance
    self.group_loan_weekly_uncollectibles.each do |x|
      x.create_allowance_transaction_data_from_uncollectible
    end
  end
  
  def unconfirm_uncollectible_allowance
    self.group_loan_weekly_uncollectibles.each do |x|
      x.create_contra_allowance_transaction_data
    end
  end
  
  
  # week 1: full member. week 2: 1 member run away
  # week 3 : another member run away 
  # now we are in week 3... 
  # the question is: how much is the amount receivable in week 2 ? 
  
  def active_group_loan_memberships
    current_week_number = self.week_number
    
    if not group_loan.is_closed?
      # puts "NON-CLOSED case.. the current week number: #{current_week_number}"
      return group_loan.group_loan_memberships.where{
        (is_active.eq true) | 
        (
          ( is_active.eq false) & 
          ( deactivation_week_number.gt current_week_number)
        )
        
      }
    else
      # GROUP_LOAN_DEACTIVATION_CASE
      # puts "Inside the closed group loan"
      return group_loan.group_loan_memberships.where{
        ( is_active.eq false ) & 
        (
          (
            ( deactivation_case.eq GROUP_LOAN_DEACTIVATION_CASE[:finished_group_loan] ) & 
            ( deactivation_week_number.eq nil)
          ) | 
          (
            ( deactivation_week_number.not_eq nil) & 
            ( deactivation_week_number.gt current_week_number) & 
            ( deactivation_case.not_eq GROUP_LOAN_DEACTIVATION_CASE[:finished_group_loan] ) 
          )
        )
        
        
      }
    end
  end
  
  
  
  
  def extract_base_amount 
    amount = BigDecimal('0')
    self.active_group_loan_memberships.joins(:group_loan_product).each do |glm|
      amount += glm.group_loan_product.weekly_payment_amount
    end
    
    return amount 
  end
  
  
  def remaining_weeks 
    current_week_number = self.week_number 
    total_weeks = self.group_loan.loan_duration 
    
    remaining_weeks = total_weeks - current_week_number + 1
  end
  
  def extract_run_away_end_of_cycle_resolution_default_amount
    amount = BigDecimal('0')
    remaining_weeks = self.remaining_weeks
    
    self.group_loan_run_away_receivables.joins(:group_loan_membership => [:group_loan_product]).
          where(:payment_case => GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:end_of_cycle]).each do |gl_rar|
            
      amount += gl_rar.group_loan_membership.group_loan_product.principal*remaining_weeks
    end
    
    return amount 
  end
  
  
  def premature_clearance_group_loan_memberships
    current_week_number = self.week_number
    group_loan.group_loan_memberships.where{
      ( is_active.eq false) & 
      ( deactivation_week_number.eq current_week_number) & 
      ( deactivation_case.eq GROUP_LOAN_DEACTIVATION_CASE[:premature_clearance] ) 
    }  
  end
  
  def extract_run_away_weekly_bail_out_amount
    amount = BigDecimal('0')
    current_week_number = self.week_number
    
    
    run_away_bail_out_list = []
    group_loan.group_loan_weekly_collections.
      where{week_number.lte current_week_number}.order("week_number ASC").each do |weekly_collection|
      
      weekly_collection.group_loan_run_away_receivables.
          where(:payment_case => GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly]).each do |gl_rar|
            
        run_away_bail_out_list << gl_rar.group_loan_membership.group_loan_product.weekly_payment_amount
      end
      
      number_of_premature_clearance_starting_this_week = weekly_collection.premature_clearance_group_loan_memberships.count
      # puts "week : #{weekly_collection.week_number}"
      # puts "number_of_premature_clearance_starting_this_week: #{number_of_premature_clearance_starting_this_week}"
      if number_of_premature_clearance_starting_this_week != 0 
        this_week_active_glm_count = self.active_group_loan_memberships.count 
        multiplier = this_week_active_glm_count /  (this_week_active_glm_count + number_of_premature_clearance_starting_this_week).to_f
        # we added multiplier since there are portion of run_away_bail_out paid by the premature clearance member 
        run_away_bail_out_list = run_away_bail_out_list.map {|x| x*multiplier}
      end
        
    end
    
    sum = BigDecimal('0')
    run_away_bail_out_list.each { |a| sum+=a }
    return sum
  end
  
  
  
  def extract_uncollectible_weekly_payment_amount 
    self.group_loan_weekly_uncollectibles.sum("amount")
  end
  
  def uncollectible_group_loan_membership_id_list
    self.group_loan_weekly_uncollectibles.map{|x| x.group_loan_membership_id }
  end
  
  def extract_uncollectible_weekly_payment_default_amount
    self.group_loan_weekly_uncollectibles.sum("principal")
  end
  
  def extract_premature_clearance_payment_amount
    return self.group_loan_premature_clearance_payments.sum("amount")
  end
  
  
=begin
first_gl = GroupLoan.first 
third_collection = first_gl.group_loan_weekly_collections.where(:week_number => 3).first

fourth_collection = first_gl.group_loan_weekly_collections.where(:week_number => 4).first


third_collection.amount_receivable
fourth_collection.amount_receivable
=end

  def total_amount
    total_amount =  extract_base_amount +  # from all still active member 
                    extract_run_away_weekly_bail_out_amount +  # amount used to bail out the run_away weekly_resolution
                    extract_premature_clearance_payment_amount -  #premature clearance for that week 
                    extract_uncollectible_weekly_payment_amount
    
    return total_amount 
  end
  
  def amount_receivable 
    return GroupLoan.rounding_up( total_amount  , DEFAULT_PAYMENT_ROUND_UP_VALUE ) 
  end
  
  def group_loan_weekly_uncollectible_count
    self.group_loan_weekly_uncollectibles.count 
  end
  
  def group_loan_deceased_clearance_count
    group_loan.group_loan_memberships.where(
      :is_active => false,
      :deactivation_case => GROUP_LOAN_DEACTIVATION_CASE[:deceased],
      :deactivation_week_number =>  self.week_number 
    ).count
  end
  
  def group_loan_run_away_receivable_count
    group_loan.group_loan_memberships.where(
      :is_active => false,
      :deactivation_case => GROUP_LOAN_DEACTIVATION_CASE[:run_away],
      :deactivation_week_number =>  self.week_number 
    ).count
  end
  
  def group_loan_premature_clearance_payment_count 
    group_loan.group_loan_memberships.where(
      :is_active => false,
      :deactivation_case => GROUP_LOAN_DEACTIVATION_CASE[:premature_clearance],
      :deactivation_week_number =>  self.week_number 
    ).count
  end
  
   
end
