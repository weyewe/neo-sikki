class GroupLoanRunAwayReceivable < ActiveRecord::Base
  attr_accessible :member_id, :amount_receivable, 
                  :group_loan_id, :payment_case , :group_loan_membership_id , 
                  :group_loan_weekly_collection_id
  has_many :group_loan_run_away_receivable_payments
  belongs_to :group_loan_membership 
  belongs_to :group_loan_weekly_collection
  
  validate :valid_payment_case
  validates_presence_of :payment_case
  
  belongs_to :group_loan 
  
  after_create :update_group_loan_run_away_amount_receivable  
  
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
  
  def update_group_loan_run_away_amount_receivable
    group_loan = self.group_loan 
    amount = BigDecimal('0')
    group_loan.group_loan_run_away_receivables.each do |x|
      amount += x.amount_receivable 
    end
    group_loan.run_away_amount_receivable =  amount 
    group_loan.save
    
    # self.amount_receivable
    
    group_loan.update_default_payment_amount_receivable   
     # by default, it is weekly. So, there is no need to update default_loan amount 
  end
  
  def set_payment_case( params ) 
    if self.group_loan_run_away_receivable_payments.count != 0 
      self.errors.add(:generic_errors, "Sudah ada pembayaran")
      return self 
    end
    
    if self.group_loan_weekly_collection.is_collected? || 
       self.group_loan_weekly_collection.is_confirmed? 
         self.errors.add(:generic_errors, "Sudah konfirmasi pembayaran mingguan")
         return self 
    end
    
    # if the week when this payment has been reported has been confirmed... then, 
    # you can't change anymore 
    
    self.payment_case = params[:payment_case]
    if  self.save 
      group_loan.update_default_payment_amount_receivable   
    end 
  end
  
  
  # is it needed to be closed? no need. 
  # def close
  #   self.is_closed = true 
  #   self.save 
  #   
  #   
  #   # over here, trigger the accounting shite to
  #   # 1. loan provision
  #   # 2. write-off interest receivable => as bad expense 
  #   
  # end
  
  
end
