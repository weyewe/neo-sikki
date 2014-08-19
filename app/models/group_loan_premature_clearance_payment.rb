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
  
  # validate :group_loan_weekly_collection_must_be_uncollected
  # validate :next_weekly_collection_must_be_available # reason: the deactivation will start from next week
  validate :no_uncleared_weekly_uncollectible
  validate :group_loan_must_not_be_closed
  # validate :member_must_be_active
  
  def group_loan_must_not_be_closed
    return if  not all_fields_present?
    
    if self.group_loan.is_closed?
      self.errors.add(:generic_errors, "GroupLoan is closed")
      return self 
    end
  end
  
  def member_must_be_active
    return if  not all_fields_present?
    
    member = self.group_loan_membership.member
    if not group_loan_membership.is_active? 
      self.errors.add(:generic_errors, "Member #{member.name} tidak aktif")
      return self 
    end
  end

  
  def all_fields_present?
    group_loan_id.present? and 
    group_loan_membership_id.present? and 
    group_loan_weekly_collection_id.present? 
  end
  
  def group_loan_weekly_collection_must_be_uncollected
    return if not all_fields_present?
    # return if self.is_confirmed? 
    # how can we differentiate the unconfirm and confirm phase? 
    
    # in the case of create and update 
    if    self.group_loan_weekly_collection.is_collected?   
      self.errors.add(:generic_errors, "The group loan weekly collection is collected ")
      return self 
    end
    
    
    
    
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
    return if self.is_confirmed? 
    
    current_weekly_collection = group_loan_weekly_collection
    next_weekly_collection = group_loan.group_loan_weekly_collections.
                                where(:week_number => current_weekly_collection.week_number + 1 ).first
                                
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
    
    new_object.group_loan_weekly_collection_must_be_uncollected
    new_object.member_must_be_active
    new_object.next_weekly_collection_must_be_available
    return new_object if new_object.errors.size != 0  
    
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
    
    self.group_loan_weekly_collection_must_be_uncollected
    self.member_must_be_active
    self.next_weekly_collection_must_be_available
    
    return self if self.errors.size != 0
    self.update_amount if self.save 
    
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
    
    contribution_amount = group_loan_weekly_collection.extract_run_away_weekly_bail_out_amount* remaining_weeks*1 / group_loan_weekly_collection.active_group_loan_memberships.count.to_f
    
    GroupLoan.rounding_up( contribution_amount  , DEFAULT_PAYMENT_ROUND_UP_VALUE) 
  end
  
  def run_away_end_of_cycle_resolved_bail_out_contribution
    # group_loan_weekly_collection  
    
    current_week_number = group_loan_weekly_collection.week_number
    # puts "2211 currentweeknumber: #{current_week_number}"
    # puts "group_loan: #{self.group_loan}"
    
    # puts "group_loan.id: #{self.group_loan.id}"
    # puts "class of loan duration: #{group_loan.loan_duration.class}"
    awesome_loan_duration = group_loan.loan_duration
    # puts "extracted_loan_duration: #{awesome_loan_duration}"
    # puts "group_loan.loan_duration: #{self.group_loan.loan_duration}"
    
    remaining_weeks = awesome_loan_duration -  current_week_number
    # puts "remaining_weeks: #{remaining_weeks}"
     
    amount = BigDecimal('0')
    
    run_away_end_of_cycle_resolved = group_loan.group_loan_run_away_receivables.joins(:group_loan_weekly_collection).
        where{
          (payment_case.eq GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:end_of_cycle]) & 
          (group_loan_weekly_collection.week_number.lte current_week_number)
        }
        
    return amount  if run_away_end_of_cycle_resolved.count == 0 
      
    run_away_end_of_cycle_resolved.each do |gl_rar|
      amount +=  gl_rar.group_loan_membership.group_loan_product.weekly_payment_amount
    end
    
    contribution_amount = amount* remaining_weeks*1/group_loan_weekly_collection.active_group_loan_memberships.count.to_f
    
    GroupLoan.rounding_up( contribution_amount  , DEFAULT_PAYMENT_ROUND_UP_VALUE) 
  end
 
  
  # requirement for savings_entry creation
  def member
    self.group_loan_membership.member 
  end
  
  
  def premature_clearance_deposit_amount
    run_away_end_of_cycle_resolved_bail_out_contribution + run_away_weekly_resolved_bail_out_contribution
  end
  
  def confirm
    if self.is_confirmed?
      self.errors.add(:generic_errors, "Sudah konfirmasi")
      return self
    end
    
    
    
    self.is_confirmed = true 
    
    if not self.save 
      puts "inside the group loan premature clearance payment"
      puts "The errors:"
      self.errors.messages.each {|x| puts "error: #{x}"}
    end
    
    
    
    
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
    
    
    # amount_for_premature_clearance_deposit = self.group_loan_weekly_collection.amount_receivable - normal_weekly_collection_without_deposit
    self.group_loan.update_premature_clearance_deposit( premature_clearance_deposit_amount ) 
    
  end
  
  
  # GroupLoanPrematureClearancePayment.where(:group_loan_id => 19).each {|x| x.is_confirmed = false; x.save}
  
  def unconfirm
    if not self.is_confirmed?
      self.errors.add(:generic_errors, "Belum konfirmasi premature clearance")
      return self 
    end
    self.group_loan.update_premature_clearance_deposit( -1*premature_clearance_deposit_amount ) 
    
    glm = self.group_loan_membership
    glm.is_active = true 
    glm.deactivation_case =  nil 
    glm.deactivation_week_number =  nil 
    if glm.save  
      
      # SavingsEntry.create_group_loan_compulsory_savings_withdrawal( self , self.group_loan_membership.total_compulsory_savings )  
      
      compulsory_savings_withdrawal_array = SavingsEntry.where(
        :savings_source_id => self.id,
        :savings_source_type => self.class.to_s, 
        :savings_status => SAVINGS_STATUS[:group_loan_compulsory_savings],
        :direction => FUND_TRANSFER_DIRECTION[:outgoing],
        :financial_product_id => self.group_loan_id ,
        :financial_product_type => self.group_loan.class.to_s,
        :member_id => glm.member.id,
        :is_confirmed => true 
      )
      total_amount = BigDecimal("0")
      compulsory_savings_withdrawal_array.each do |x|
        total_amount += x.amount 
        x.destroy 
      end
      
      glm.update_total_compulsory_savings( total_amount )
      
      
      
      # if remaining_compulsory_savings > BigDecimal('0')
      #   SavingsEntry.create_savings_account_group_loan_premature_clearance_addition( self , self.remaining_compulsory_savings )  
      # end 
      
      remaining_compulsory_savings_array = SavingsEntry.where(
        :savings_source_id => self.id,
        :savings_source_type => self.class.to_s,
        :savings_status => SAVINGS_STATUS[:savings_account],
        :direction => FUND_TRANSFER_DIRECTION[:incoming],
        :financial_product_id =>  self.group_loan.id  ,
        :financial_product_type => self.group_loan.class.to_s ,
        :member_id => glm.member.id,
        :is_confirmed => true 
      )
      
      total_remaining_amount = BigDecimal("0")
      remaining_compulsory_savings_array.each do |x|
        total_amount += x.amount 
        x.destroy
      end
      
      member = glm.member 
      member.update_total_savings_account( -1*total_amount)
    else
      puts "44321 fail to update glm"
    end
    
    
    self.is_confirmed = false 
    if self.save 
    else
      puts "44511 fail to save group loan premature clearance payment"
      self.errors.messages.each {|x| puts "Err_msg: #{x}"}
    end
    
  end
  
  
end
