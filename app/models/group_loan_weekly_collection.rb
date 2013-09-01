class GroupLoanWeeklyCollection < ActiveRecord::Base
  attr_accessible :group_loan_id, :week_number 
  belongs_to :group_loan 
  validates_presence_of :group_loan_id, :week_number 
  
  
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
    
    self.collection_datetime = params[:collection_datetime]
    
    if self.collection_datetime.present?
      self.is_collected = true 
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
                          where(:deactivation_case => GROUP_LOAN_DEACTIVATION_CASE[:run_away]  )
    
    
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
        :group_loan_run_away_receivable_id => glm.group_loan_run_away_receivable.id ,
        :group_loan_weekly_collection_id   => self.id ,
        :group_loan_membership_id          => glm.id  ,
        :group_loan_id                     => self.group_loan_id ,
        :amount                            =>  glm.group_loan_product.weekly_payment_amount   ,
        :payment_case                      => GROUP_LOAN_RUN_AWAY_RECEIVABLE_PAYMENT_CASE[:weekly]
      })
      
      
    end
    
  end
  
  
  
  def confirm
    if not self.is_collected?
      self.errors.add(:generic_errors, "Belum melakukan pengumpulan di minggu ini")
      return self 
    end
    
    if self.is_collected? and self.is_confirmed?
      self.errors.add(:generic_errors, "Sudah dikonfirmasi")
      return self 
    end
    
    
    self.confirmation_datetime = DateTime.now 
    self.is_confirmed = true 
    self.save 
    
    self.create_group_loan_weekly_payments 
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
  
  def extract_run_away_weekly_resolution_amount
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
    
    return amount
  end
  
  def extract_uncollectable_weekly_payment_amount 
    return BigDecimal('0')
  end
  
  def amount_receivable 
    
    total_amount =  extract_base_amount + 
                    extract_run_away_weekly_resolution_amount - 
                    extract_uncollectable_weekly_payment_amount 
    
    return total_amount 
  end
  
  
   
end
