class GroupLoanWeeklyCollection < ActiveRecord::Base
  attr_accessible :group_loan_id, :week_number 
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
    active_glm_id_list = self.active_group_loan_memberships.map {|x| x.id }
    run_away_glm_id_list = group_loan.
                          group_loan_memberships.joins(:group_loan_run_away_receivable).
                          where{
                            (deactivation_case.eq  GROUP_LOAN_DEACTIVATION_CASE[:run_away] ) & 
                            (group_loan_run_away_receivable.payment_case.eq GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly])
                          }.map{|x| x.id }
                          
                          
    
    
    # active_glm_id_list = (active_glm_id_list + run_away_glm_list ).uniq
    
    
    # for the normal payment 
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
    
    
  end
  
  
  
  
  
  def update_group_loan_bad_debt_allowance
    group_loan.update_bad_debt_allowance(                 
                      self.extract_uncollectible_weekly_payment_default_amount + 
                      self.extract_run_away_end_of_cycle_resolution_default_amount
    )
  end
  
  
  def confirm(params)
    # puts "gonna confirm week #{self.week_number}"
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
        self.group_loan_weekly_collection_voluntary_savings_entries.each do |x|
          x.confirm
        end
        self.confirmed_at = params[:confirmed_at]
        self.is_confirmed = true 
        self.save 

        self.create_group_loan_weekly_payments 
        
        self.confirm_premature_clearances
        self.update_group_loan_bad_debt_allowance  # from uncollectible +  run_away_member
        
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
    next_week_week_number = next_week_collection.week_number
    
    if not next_week_collection.nil?
      if  next_week_collection.is_collected?
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
    
    return false 
  end
  
  
  def uncreate_group_loan_weekly_payments
    GroupLoanWeeklyPayment.where(
      :group_loan_id => self.group_loan_id,
      :group_loan_weekly_collection_id => self.id ,
    ).each do |glwp|
      glwp.delete_object
    end
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
    if self.can_be_unconfirmed?
      return self 
    end
    
    begin
      ActiveRecord::Base.transaction do
        
        #0. unconfirm summary on bad debt allowance in group loan 
        group_loan.update_bad_debt_allowance(      
                          -1 * (
                            self.extract_uncollectible_weekly_payment_default_amount + 
                            self.extract_run_away_end_of_cycle_resolution_default_amount
                          )
        )
        group_loan.save
        
        
        #1.  unconfirm all voluntary savings 
        self.unconfirm_weekly_collection_voluntary_savings 
        
        self.confirmed_at = nil
        self.is_confirmed = false  
        self.save 
        
        #2.  unconfirm all compulsory savings 
        self.uncreate_group_loan_weekly_payments   # ok  
        
        #3. unconfirm premature clearance
        self.unconfirm_premature_clearances
        
       
        
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
  
  def uncreate_things
    group_loan = self.group_loan 
    
    
    # deceased 
    
    group_loan.group_loan_memberships.where(
      :deactivation_case =>  GROUP_LOAN_DEACTIVATION_CASE[:deceased] ,
      :is_active => false, 
      :deactivation_week_number => self.week_number 
    ).each do |deceased_glm|
      
      member = deceased_glm.member  
      member.undo_mark_as_deceased(self)
    end
    
      
    # run_away
    group_loan.group_loan_memberships.where(
      :deactivation_case =>  GROUP_LOAN_DEACTIVATION_CASE[:run_away] ,
      :is_active => false, 
      :deactivation_week_number => self.week_number 
    ).each do |run_away_glm|
      
      member = run_away_glm.member  
      member.undo_mark_as_run_away(self)
    end
    
    
    # uncollectibles
    self.group_loan_weekly_uncollectibles.each do |x|
      x.unclear
      x.uncollect
      x.destroy 
    end
    
    # prematures 
    self.group_loan_premature_clearance_payments.each do |x|
      x.unconfirm
      x.destroy 
    end
  end
  
  
  def confirm_premature_clearances
    self.group_loan_premature_clearance_payments.each do |x|
      x.confirm 
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
  
  
  def extract_run_away_end_of_cycle_resolution_default_amount
    amount = BigDecimal('0')
    current_week_number = self.week_number 
    total_weeks = self.group_loan.loan_duration 
    
    remaining_weeks = total_weeks - current_week_number + 1 
    
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
  def amount_receivable 
    
    total_amount =  extract_base_amount +  # from all still active member 
                    extract_run_away_weekly_bail_out_amount +  # amount used to bail out the run_away weekly_resolution
                    extract_premature_clearance_payment_amount -  #premature clearance for that week 
                    extract_uncollectible_weekly_payment_amount    
           
    
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
