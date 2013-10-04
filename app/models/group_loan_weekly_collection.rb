class GroupLoanWeeklyCollection < ActiveRecord::Base
  attr_accessible :group_loan_id, :week_number 
  belongs_to :group_loan 
  validates_presence_of :group_loan_id, :week_number 
  
  has_many :group_loan_run_away_receivables 
  has_many :group_loan_weekly_uncollectibles
  has_many :group_loan_premature_clearance_payments 
  
  
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
    
    
    self.premature_clearance_deposit_usage = BigDecimal( params[:premature_clearance_deposit_usage] ||  '0' )
    
    if params[:collected_at].nil? or not params[:collected_at].is_a?(DateTime)
      self.errors.add(:collected_at, "Harus ada tanggal penerimaan pembayaran")
      return self 
    end
    
    self.collected_at = params[:collected_at]
    self.is_collected = true  
    
    
    if self.premature_clearance_deposit_usage > self.group_loan.remaining_premature_clearance_deposit
      msg = "Jumlah uang titipan tersisa: #{self.group_loan.remaining_premature_clearance_deposit.to_s}"
      self.errors.add(:premature_clearance_deposit_usage, msg )
      return self
    end
    
    self.save 
  end
  
  def create_group_loan_weekly_payments
    # do weekly payment for all active members
    # minus those that can't pay  (the dead and running away is considered as non active)    
    active_glm_id_list = group_loan.active_group_loan_memberships.map {|x| x.id }
    no_payment_id_list = [] 
    run_away_glm_list = group_loan.
                          group_loan_memberships.joins(:group_loan_run_away_receivable).
                          where{
                            (deactivation_case.eq  GROUP_LOAN_DEACTIVATION_CASE[:run_away] ) & 
                            (group_loan_run_away_receivable.payment_case.eq GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly])
                          }
                          
                          
    
    
    active_glm_id_list -= no_payment_id_list 
    
    
    # for the normal payment 
    active_glm_id_list.each do |glm_id|
      GroupLoanWeeklyPayment.create :group_loan_membership_id => glm_id,
                                    :group_loan_id => self.group_loan_id,
                                    :group_loan_weekly_collection_id => self.id 
    end
    
    # for the run_away_payment 
    run_away_glm_list.each do |glm|
      GroupLoanRunAwayReceivablePayment.create({
        # the link to the member, glm, or group_loan_run_away_receivable is a bonus
        # we don't know what it is for yet. but, just better to dump it.
        # we can optimize later. 
        # The core info needed: group_loan_id, weekly_collection_id, amount
        :group_loan_run_away_receivable_id => glm.group_loan_run_away_receivable.id ,
        :group_loan_weekly_collection_id   => self.id ,
        :group_loan_membership_id          => glm.id  ,
        :group_loan_id                     => self.group_loan_id ,
        :amount                            =>  glm.group_loan_product.weekly_payment_amount   ,
        :payment_case                      => GROUP_LOAN_RUN_AWAY_RECEIVABLE_PAYMENT_CASE[:weekly]
      })
      
      
    end
    
  end
  
  
  
  def update_group_loan_default_payment 
    group_loan.update_default_amount(                 
                      self.extract_uncollectible_weekly_payment_default_amount + 
                      self.extract_run_away_end_of_cycle_resolution_default_amount
    )
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
    
    self.confirmed_at = params[:confirmed_at]
    self.is_confirmed = true 
    self.save 
    
    self.create_group_loan_weekly_payments 
    # self.group_loan.update_default_payment_amount_receivable
    self.update_group_loan_default_payment  # from uncollectible +  run_away_member
    self.confirm_premature_clearances
  end
  
  
  def unconfirm
    # if it is unconfirmable (the next group loan weekly collection is not confirmed?)
    # and there is no corner cases created for the next group 
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
  
  def extract_run_away_weekly_resolution_amount
    # return BigDecimal('0')
    amount = BigDecimal('0')
    current_week_number = self.week_number
    
    group_loan.group_loan_memberships.joins(:group_loan_run_away_receivable).where{
      ( deactivation_case.eq GROUP_LOAN_DEACTIVATION_CASE[:run_away] ) & 
      ( deactivation_week_number.lte current_week_number ) & 
      (
        group_loan_run_away_receivable.payment_case.eq GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly] 
      )
    }.each do |glm|
      amount += glm.group_loan_product.weekly_payment_amount
    end
    
    # adjust the weekly_amount, deduct the premature_clearance 
    
    
    
    return amount 
  end
  
  def extract_weekly_run_away_premature_clearance_paid_amount
    offset_amount = BigDecimal('0')
    current_week_number = self.week_number
    group_loan.group_loan_memberships.where{
      ( is_active.eq false) & 
      ( deactivation_week_number.lte current_week_number) & 
      ( deactivation_case.eq GROUP_LOAN_DEACTIVATION_CASE[:premature_clearance] ) 
    }.each do |glm|
      offset_amount += glm.group_loan_premature_clearance_payment.extract_run_away_default_weekly_payment_share
    end
    
    return offset_amount
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
  
  def amount_receivable 
    total_amount =  extract_base_amount + 
                    extract_run_away_weekly_resolution_amount + 
                    extract_premature_clearance_payment_amount -  #premature clearance for that week 
                    extract_uncollectible_weekly_payment_amount  -
                    extract_weekly_run_away_premature_clearance_paid_amount
                     
    
    return total_amount 
  end
  
  
   
end
