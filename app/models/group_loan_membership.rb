class GroupLoanMembership < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :member 
  belongs_to :group_loan 
   
  belongs_to :group_loan_product 
  has_many :group_loan_weekly_payments
  
  has_one :group_loan_disbursement  #checked  
  has_one :group_loan_port_compulsory_savings 
  has_one :group_loan_run_away_receivable
  has_many :group_loan_weekly_uncollectibles
  
  # has_one :group_loan_default_payment 
  has_one :group_loan_premature_clearance_payment 
  
    
  
  validates_presence_of :group_loan_id, :member_id , :group_loan_product_id 
  
  validate :no_active_membership_of_another_group_loan
  
  def no_active_membership_of_another_group_loan
    return if self.persisted? or not self.member_id.present? 
    
    if GroupLoanMembership.where(:is_active => true, :member_id => self.member_id ).count != 0
      self.errors.add(:member_id , "Sudah ada pinjaman di group lainnya")
    end
  end
  
  def self.create_object( params ) 
    new_object = self.new 
    new_object.group_loan_id      = params[:group_loan_id] 
    new_object.member_id          = params[:member_id]
    new_object.group_loan_product_id          = params[:group_loan_product_id]
    new_object.save
    
    return new_object 
  end
  
  def update_object( params ) 
    return nil if self.group_loan.is_started? 
    self.member_id = params[:member_id]
    self.group_loan_product_id          = params[:group_loan_product_id]
    self.save
  end
  
  def delete_object
    return nil if self.group_loan.is_started? 
    
    self.destroy 
  end 
     
  def port_compulsory_savings_to_voluntary_savings
    GroupLoanPortCompulsorySavings.create :group_loan_membership_id => self.id 
    
    self.update_total_compulsory_savings
    self.update_total_voluntary_savings
  end
    
  
  
  def update_total_compulsory_savings(amount)
    self.total_compulsory_savings += amount 
    self.save 
  end
  # def update_total_compulsory_savings
  #   incoming = member.savings_entries.where(
  #     :savings_status => SAVINGS_STATUS[:group_loan_compulsory_savings],
  #     :financial_product_type => GroupLoan.to_s, 
  #     :financial_product_id => self.group_loan_id ,
  #     :direction => FUND_TRANSFER_DIRECTION[:incoming]
  #   ).sum("amount")   
  #   
  #   outgoing = member.savings_entries.where(
  #     :savings_status => SAVINGS_STATUS[:group_loan_compulsory_savings],
  #     :financial_product_type => GroupLoan.to_s, 
  #     :financial_product_id => self.group_loan_id ,
  #     :direction => FUND_TRANSFER_DIRECTION[:outgoing]
  #   ).sum("amount")
  #   
  #   self.total_compulsory_savings = incoming - outgoing 
  #   self.save 
  # end
  
=begin
  Corner Case : Deceased member 
=end

  def remaining_deceased_principal_payment
    
      remaining_number_of_weeks = self.group_loan.loan_duration - 
                                  self.deactivation_week_number + 
                                  1 # for the week where deceased is declared
                                  
      return remaining_number_of_weeks * self.group_loan_product.principal 
    
  end
  
=begin
  Corner Case: RunAway member
=end

  def run_away_remaining_group_loan_payment
    total_weeks = self.group_loan.number_of_collections 
    paid_weeks_count = self.group_loan_weekly_payments.count 
    
    (total_weeks - paid_weeks_count ) * group_loan_product.weekly_payment_amount
    
    # for the default payment, will be recalculated, reducing the pool of default bearer. 
  end
  
end
