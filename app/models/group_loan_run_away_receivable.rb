class GroupLoanRunAwayReceivable < ActiveRecord::Base
  attr_accessible :member_id, :amount_receivable, 
                  :group_loan_id, :payment_case , :group_loan_membership_id , 
                  :group_loan_weekly_collection_id
  has_many :group_loan_run_away_receivable_payments
  belongs_to :group_loan_membership 
  belongs_to :group_loan_weekly_collection
  belongs_to :member
  
  validate :valid_payment_case
  validates_presence_of :payment_case
  
  belongs_to :group_loan 
  
  after_create :update_group_loan_run_away_amount_receivable  
  after_create :create_transaction_data_for_run_away_bad_debt_allocation
  
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
    # group_loan.run_away_amount_receivable =  amount 
    group_loan.save
  end
  
  def create_transaction_data_for_run_away_bad_debt_allocation
    message = ""
    
    ta = TransactionData.create_object({
      :transaction_datetime => self.collected_at,
      :description =>  message,
      :transaction_source_id => group_loan_weekly_collection.id , 
      :transaction_source_type => group_loan_weekly_collection.class.to_s ,
      :code => TRANSACTION_DATA_CODE[:group_loan_weekly_collection_voluntary_savings],
      :is_contra_transaction => false 
    }, true )
    
     
    
    TransactionDataDetail.create_object(
      :transaction_data_id => ta.id,        
      :account_id          => Account.find_by_code(ACCOUNT_CODE[:main_cash_leaf][:code]).id      ,
      :entry_case          => NORMAL_BALANCE[:debit]     ,
      :amount              => total_compulsory_savings + total_principal +  total_interest_revenue,
      :description => message
    )
    
    TransactionDataDetail.create_object(
      :transaction_data_id => ta.id,        
      :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_interest_revenue_leaf][:code]).id        ,
      :entry_case          => NORMAL_BALANCE[:credit]     ,
      :amount              => total_interest_revenue,
      :description => message
    )
    TransactionDataDetail.create_object(
      :transaction_data_id => ta.id,        
      :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_ar_leaf][:code]).id        ,
      :entry_case          => NORMAL_BALANCE[:credit]     ,
      :amount              => total_principal,
      :description => message
    )
    TransactionDataDetail.create_object(
      :transaction_data_id => ta.id,        
      :account_id          => Account.find_by_code(ACCOUNT_CODE[:compulsory_savings_leaf][:code]).id        ,
      :entry_case          => NORMAL_BALANCE[:credit]     ,
      :amount              => total_compulsory_savings,
      :description => message
    )
    
    ta.confirm
  end
  
  def set_payment_case( params ) 
    # if self.group_loan_run_away_receivable_payments.count != 0 
    #   self.errors.add(:generic_errors, "Sudah ada pembayaran")
    #   return self 
    # end
    
    if self.group_loan_weekly_collection.is_collected? || 
       self.group_loan_weekly_collection.is_confirmed? 
         self.errors.add(:generic_errors, "Sudah konfirmasi pembayaran mingguan")
         return self 
    end
    
    # if the week when this payment has been reported has been confirmed... then, 
    # you can't change anymore 
    
    self.payment_case = params[:payment_case]
    self.save  
  end
  
   
  
  
end
