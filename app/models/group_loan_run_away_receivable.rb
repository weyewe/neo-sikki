class GroupLoanRunAwayReceivable < ActiveRecord::Base
  attr_accessible :member_id, :amount_receivable, 
                  :group_loan_id, :payment_case , :group_loan_membership_id 
  has_many :group_loan_run_away_receivable_payments
  belongs_to :group_loan_membership 
  
  validate :valid_payment_case
  validates_presence_of :payment_case
  
  def valid_payment_case
    return if not payment_case.present?
      
      
    array = [
        GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly],
        GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:end_of_cycle]
      ]
      
    if not array.include?( payment_case.to_i )
      self.errors.add(:payment_case, "Metode Penagihan tidak valid")
    end
    
  end
  
  def set_payment_case( params ) 
    if self.group_loan_run_away_receivable_payments.count != 0 
      self.errors.add(:generic_errors, "Sudah ada pembayaran")
      return self 
    end
    
    self.payment_case = params[:payment_case]
    self.save 
  end
end
