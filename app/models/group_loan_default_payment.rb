=begin
  On Loan disbursement, every member will have one group loan default payment. 
  
  CompulsorySavings deduction at the end of group_loan cycle will be taken from this number. 
  It will be updated on every:
    1. extra GroupLoanAdditionDefaultPayment 
=end

class GroupLoanDefaultPayment < ActiveRecord::Base
  attr_accessible :group_loan_id, :group_loan_membership_id 
  belongs_to :group_loan
  belongs_to :group_loan_membership 
  
  def execute_compulsory_savings_deduction
    return if self.amount_receivable <=  BigDecimal('0')
    
    compulsory_savings_deduction_amount = BigDecimal('0')
    
    if group_loan_membership.total_compulsory_savings > amount_receivable
      self.compulsory_savings_deduction = amount_receivable
    else
      self.compulsory_savings_deduction =  group_loan_membership.total_compulsory_savings
    end 
    
    self.remaining_amount_receivable = self.amount_receivable - self.compulsory_savings_deduction
    self.save 
    
    SavingsEntry.create_group_loan_compulsory_savings_withdrawal( self,  self.compulsory_savings_deduction  )
      
  end
end
