=begin
  Least priority
  
  Default payment from
  1. Run away member
  2. uncollectible 
  => Goes first. 
  
  Then, the premature clearance will takes place. 
=end

# group_loan_weekly_collection shows the weekly collection where there is this premature clearance declaration
# but the actual execution will be on the next week. 
class GroupLoanPrematureClearancePayment < ActiveRecord::Base
  belongs_to :group_loan
  belongs_to :group_loan_membership
  belongs_to :group_loan_weekly_collection
  
  has_many :savings_entries, :as => :savings_source
  
  validates_presence_of :group_loan_id, :group_loan_membership_id , :group_loan_weekly_collection_id
  
  validates_uniqueness_of :group_loan_membership_id 
  
  validate :group_loan_weekly_collection_must_be_uncollected
  validate :next_weekly_collection_must_be_available # reason: the deactivation will start from next week
  validate :no_uncleared_weekly_uncollectible
  
  def all_fields_present?
    group_loan_id.present? and 
    group_loan_membership_id.present? and 
    group_loan_weekly_collection_id.present? 
  end
  
  def group_loan_weekly_collection_must_be_uncollected
    return if not all_fields_present?
    return if self.group_loan_weekly_collection.is_confirmed?   
    
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
  
  def no_uncleared_weekly_uncollectible
    return if not all_fields_present? 
    
    if self.group_loan_membership.group_loan_weekly_uncollectibles.where(:is_cleared => false ).count != 0 
      self.errors.add(:generic_errors, "Ada pembayaran tak tertagih")
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
  
  
  def total_principal_return
    total_unpaid_week = group_loan.number_of_collections - 
                    group_loan_weekly_collection.week_number 
    return  group_loan_membership.group_loan_product.principal * total_unpaid_week
  end
  
  # including the current week that will be confirmed along with the premature clearance
  def available_compulsory_savings
    group_loan_weekly_collection.week_number  * group_loan_membership.group_loan_product.compulsory_savings 
  end
  
  # manifested in the group loan clearance payment 
  def update_amount
    # the current week is not counted. it has to be paid in full.
    # plus 1 because the current week where premature_clearance is applied has to be paid full 
    # example: premature_clearance is applied@week_2. If there are total 8 installments,
    # then, week 2 has to be paid full. and 6*principal has to be returned
    # plus + default payment 
    # total_unpaid_week = group_loan.number_of_collections - 
    #                 group_loan_weekly_collection.week_number 
    # total_principal_return =  group_loan_membership.group_loan_product.principal * total_unpaid_week
    
    # minus compulsory savings ... ? 
    # if compulsory savings > amount => amount == 0 
    # compulsory_savings_return =>  (port to voluntary savings)
    
    
    # premature clearance can't be created if there is uncollectible weekly payment on the name of this member. 
    # there is nothing can be used to deduct the compulsory_savings
    # other than end_of_cycle default payment or premature clearance
    # available_compulsory_savings = group_loan_weekly_collection.week_number  * group_loan_membership.group_loan_product.compulsory_savings 
    
    
    
    amount_payable = total_principal_return + 
                    run_away_weekly_resolved_bail_out_contribution +
                    run_away_end_of_cycle_resolved_bail_out_contribution 
       
   
   
    if available_compulsory_savings >= amount_payable
      self.remaining_compulsory_savings = available_compulsory_savings - amount_payable
      self.amount = BigDecimal('0')
    else
      self.remaining_compulsory_savings = BigDecimal('0')
      self.amount = GroupLoan.rounding_up( amount_payable - available_compulsory_savings , DEFAULT_PAYMENT_ROUND_UP_VALUE) 
    end               
     
    self.save 
  end
  
  def run_away_weekly_resolved_bail_out_contribution
    current_week_number = group_loan_weekly_collection.week_number
    remaining_weeks = group_loan.loan_duration -  current_week_number
    
    group_loan_weekly_collection.extract_run_away_weekly_bail_out_amount* remaining_weeks*1 / group_loan_weekly_collection.active_group_loan_memberships.count.to_f
  end
  
  def run_away_end_of_cycle_resolved_bail_out_contribution
    # group_loan_weekly_collection  
    current_week_number = group_loan_weekly_collection.week_number
    remaining_weeks = group_loan.loan_duration -  current_week_number
     
    amount = BigDecimal('0')
    
    run_away_end_of_cycle_resolved = group_loan.group_loan_run_away_receivables.joins(:group_loan_weekly_collection).
        where{
          (payment_case.eq GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:end_of_cycle]) & 
          (group_loan_weekly_collection.week_number.lte current_week_number)
        }
        
    return amount  if run_away_end_of_cycle_resolved.count == 0 
      
        
        
    run_away_end_of_cycle_resolved.each do |gl_rar|
      amount << gl_rar.group_loan_membership.group_loan_product.weekly_payment_amount
    end
    
    amount* remaining_weeks*1/group_loan_weekly_collection.active_group_loan_memberships.count.to_f
  end
  
  # def extract_run_away_default_weekly_payment_share 
  #   # puts "************* inside the extraction of run_away_default_payment_share"
  #   current_glm = group_loan_membership 
  #   deactivation_week = group_loan_weekly_collection.week_number + 1 
  #   amount = BigDecimal('0')
  #   
  #   
  #   weekly_run_away_glm_list =  group_loan.group_loan_memberships.joins(:group_loan_run_away_receivable, :group_loan_product).where{
  #     ( is_active.eq false ) & 
  #     ( deactivation_case.eq GROUP_LOAN_DEACTIVATION_CASE[:run_away]) & 
  #     ( deactivation_week_number.lt  deactivation_week) & 
  #     ( group_loan_run_away_receivable.payment_case.eq GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly]) 
  #   }
  #   
  #   
  #   # glm_count = group_loan.group_loan_memberships.joins(:group_loan_run_away_receivable, :group_loan_product).where{
  #   #   ( is_active.eq false ) & 
  #   #   ( deactivation_case.eq GROUP_LOAN_DEACTIVATION_CASE[:run_away]) & 
  #   #   ( deactivation_week_number.lt  deactivation_week) & 
  #   #   ( group_loan_run_away_receivable.payment_case.eq GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly]) 
  #   # }.count 
  #   
  #   glm_count = weekly_run_away_glm_list.count 
  #   
  #   # puts "The glm_count: #{glm_count}"
  #   
  #   # group_loan.group_loan_memberships.joins(:group_loan_run_away_receivable, :group_loan_product).where{
  #   #   ( is_active.eq false ) & 
  #   #   ( deactivation_case.eq GROUP_LOAN_DEACTIVATION_CASE[:run_away]) & 
  #   #   ( deactivation_week_number.lt  deactivation_week ) & 
  #   #   ( group_loan_run_away_receivable.payment_case.eq GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly]) 
  #   # }.each do |glm|
  #   #   amount += glm.group_loan_product.weekly_payment_amount  
  #   # end
  #   
  #   weekly_run_away_glm_list.each do |glm|
  #     amount += glm.group_loan_product.weekly_payment_amount
  #   end
  #   
  #   share_amount = amount / group_loan_weekly_collection.active_group_loan_memberships.count 
  #   
  #   # puts "***end of extraction"
  #   
  #   return GroupLoan.rounding_up( share_amount, DEFAULT_PAYMENT_ROUND_UP_VALUE)
  # end
  
  # requirement for savings_entry creation
  def member
    self.group_loan_membership.member 
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
    if glm.save  
      SavingsEntry.create_group_loan_compulsory_savings_withdrawal( self , self.group_loan_membership.total_compulsory_savings )  
      
      if remaining_compulsory_savings > BigDecimal('0')
        SavingsEntry.create_savings_account_group_loan_premature_clearance_addition( self , self.remaining_compulsory_savings )  
      end 
    end
    
  end
end
