class GroupLoanRunAwayReceivable < ActiveRecord::Base
  attr_accessible :member_id, :amount_receivable, :group_loan_id, :payment_case
  
end
