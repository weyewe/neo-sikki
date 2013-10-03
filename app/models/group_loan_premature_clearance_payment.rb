=begin
  Least priority
  
  Default payment from
  1. Run away member
  2. uncollectible 
  => Goes first. 
  
  Then, the premature clearance will takes place. 
=end
class GroupLoanPrematureClearancePayment < ActiveRecord::Base
  belongs_to :group_loan
  belongs_to :group_loan_membership
  belongs_to :group_loan_weekly_collection
  
  validates_presence_of :group_loan_id, :group_loan_membership_id , :group_loan_weekly_collection_id
  
  validates_uniqueness_of :group_loan_membership_id 
  
  validate :group_loan_weekly_collection_must_be_uncollected
  validate :next_weekly_collection_must_be_available # reason: the deactivation will start from next week
  
  
  def all_fields_present?
    group_loan_id.present? and 
    group_loan_membership_id.present? and 
    group_loan_weekly_collection_id.present? 
  end
  
  def group_loan_weekly_collection_must_be_uncollected
    return if not all_fields_present?
    # puts "is it confirmed?"
    return if self.group_loan_weekly_collection.is_confirmed?   
    # puts "the group loan weekly collection is not confirmed "
    first_uncollected = group_loan.first_uncollected_weekly_collection
    
    if not first_uncollected.present?
      self.errors.add(:group_loan_weekly_collection_id, "Tidak bisa premature clearance. ")
      return self
    end
    
    if first_uncollected.present? and first_uncollected.id != group_loan_weekly_collection_id
      self.errors.add(:group_loan_weekly_collection_id, "Tidak valid. Harus minggu ke #{first_uncollected.week_number}")
      return self 
    end
    
  end
  
  def next_weekly_collection_must_be_available
    return if not all_fields_present? 
    current_weekly_collection = group_loan_weekly_collection
    next_weekly_collection = group_loan.group_loan_weekly_collections.
                                where(:week_number => current_weekly_collection.week_number + 1 )
                                
    if next_weekly_collection.nil?
      self.errors.add(:group_loan_weekly_collection_id , "Tidak ada pengumpulan minggu #{current_weekly_collection.week_number + 1 }")
      return self 
    end
  end
  
  def self.create_object(params)
    new_object = self.new
    new_object.group_loan_id                    = params[:group_loan_id]
    new_object.group_loan_membership_id         = params[:group_loan_membership_id]
    new_object.group_loan_weekly_collection_id  = params[:group_loan_weekly_collection_id]
    
    
    new_object.update_amount if new_object.save 
    
    return new_object
  end
  
  def update_object(params)
    if self.is_confirmed?
      self.errors.add(:generic_errors, "Sudah Konfirmasi. Tidak bisa update")
      return self
    end
    
    self.group_loan_id                    = params[:group_loan_id]
    self.group_loan_membership_id         = params[:group_loan_membership_id]
    self.group_loan_weekly_collection_id  = params[:group_loan_weekly_collection_id]
    
    
    self.update_amount if new_object.save 
    
    return self 
  end
   
  
  def delete_object
    if self.is_confirmed?
      self.errors.add(:generic_errors, "Sudah Konfirmasi. Tidak bisa update")
      return self
    end
    
    self.destroy 
  end
  
  
  # manifested in the group loan clearance payment 
  # def update_amount
  #   # the current week is not counted. it has to be paid in full.
  #   # plus 1 because the current week where premature_clearance is applied has to be paid full 
  #   # example: premature_clearance is applied@week_2. If there are total 8 installments,
  #   # then, week 2 has to be paid full. and 6*principal has to be returned
  #   # plus + default payment 
  #   total_unpaid_week = group_loan.number_of_collections - 
  #                   group_loan_weekly_collection.week_number 
  #   total_principal =  group_loan_membership.group_loan_product.principal * total_unpaid_week
  #   
  #   
  #   
  #   total_run_away_weekly_payment_share = self.extract_run_away_default_weekly_payment_share * total_unpaid_week
  #   
  #   #  it will work in the case if there is run_away member 
  #   # and the payment is end_of_cycle => the default amount is shared inside 
  #   # group_loan_default_payment.amount_receivable 
  #   
  #   # remaining_weeks = group_loan.number_of_collections - group_loan_weekly_collection.week_number 
  #   self.amount = total_principal + 
  #                 group_loan_membership.group_loan_default_payment.amount_receivable  + 
  #                 total_run_away_weekly_payment_share
  #                 
  #   # we have to account for those run away with weekly payment. 
  #   self.save 
  # end
  
  def extract_run_away_default_weekly_payment_share 
    # puts "************* inside the extraction of run_away_default_payment_share"
    current_glm = group_loan_membership 
    deactivation_week = group_loan_weekly_collection.week_number + 1 
    amount = BigDecimal('0')
    
    
    weekly_run_away_glm_list =  group_loan.group_loan_memberships.joins(:group_loan_run_away_receivable, :group_loan_product).where{
      ( is_active.eq false ) & 
      ( deactivation_case.eq GROUP_LOAN_DEACTIVATION_CASE[:run_away]) & 
      ( deactivation_week_number.lt  deactivation_week) & 
      ( group_loan_run_away_receivable.payment_case.eq GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly]) 
    }
    
    
    # glm_count = group_loan.group_loan_memberships.joins(:group_loan_run_away_receivable, :group_loan_product).where{
    #   ( is_active.eq false ) & 
    #   ( deactivation_case.eq GROUP_LOAN_DEACTIVATION_CASE[:run_away]) & 
    #   ( deactivation_week_number.lt  deactivation_week) & 
    #   ( group_loan_run_away_receivable.payment_case.eq GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly]) 
    # }.count 
    
    glm_count = weekly_run_away_glm_list.count 
    
    # puts "The glm_count: #{glm_count}"
    
    # group_loan.group_loan_memberships.joins(:group_loan_run_away_receivable, :group_loan_product).where{
    #   ( is_active.eq false ) & 
    #   ( deactivation_case.eq GROUP_LOAN_DEACTIVATION_CASE[:run_away]) & 
    #   ( deactivation_week_number.lt  deactivation_week ) & 
    #   ( group_loan_run_away_receivable.payment_case.eq GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly]) 
    # }.each do |glm|
    #   amount += glm.group_loan_product.weekly_payment_amount  
    # end
    
    weekly_run_away_glm_list.each do |glm|
      amount += glm.group_loan_product.weekly_payment_amount
    end
    
    share_amount = amount / group_loan_weekly_collection.active_group_loan_memberships.count 
    
    # puts "***end of extraction"
    
    return GroupLoan.rounding_up( share_amount, DEFAULT_PAYMENT_ROUND_UP_VALUE)
  end
  
  
  
  def confirm
    if self.is_confirmed?
      self.errors.add(:generic_errors, "Sudah konfirmasi")
      return self
    end
    
    
    
    self.is_confirmed = true 
    self.save 
    
    glm = self.group_loan_membership
    glm.is_active = false 
    glm.deactivation_case =  GROUP_LOAN_DEACTIVATION_CASE[:premature_clearance]
    glm.deactivation_week_number = self.group_loan_weekly_collection.week_number + 1 
    glm.save 
    
    puts "premature_clearance#confirm: transaction activities and saving_entries must be created"
    puts "=> not implemented"
    
    # puts "premature_clearance#confirm \nshould create transaction activity to take the default payment money and the remaining principal payment"
    # puts "premature_clearance#confirm \nshould create savings entry to absorb compulsory savings => What should be done to the compulsory savings?"
  end
end
