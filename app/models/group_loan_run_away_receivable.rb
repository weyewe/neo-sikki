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
  
  # after_create :update_group_loan_run_away_amount_receivable  
  after_create :perform_run_away_declaration_posting
  
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
  
  def perform_run_away_declaration_posting
    remaining_weeks = group_loan.number_of_collections - group_loan_weekly_collection.week_number + 1 
    remaining_principal = group_loan_membership.group_loan_product.principal * remaining_weeks 
    
    
    
    message = "Runaway Bad Debt Allowance: Group #{group_loan.name}, #{group_loan.group_number}, member: #{member.name}"
    
    ta = TransactionData.create_object({
      :transaction_datetime => self.member.run_away_at,
      :description =>  message,
      :transaction_source_id => self.id , 
      :transaction_source_type => self.class.to_s ,
      :code => TRANSACTION_DATA_CODE[:group_loan_run_away_declaration],
      :is_contra_transaction => false 
    }, true )
    
     
    
    TransactionDataDetail.create_object(
      :transaction_data_id => ta.id,        
      :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_arae_leaf][:code]).id      ,
      :entry_case          => NORMAL_BALANCE[:debit]     ,
      :amount              => remaining_principal,
      :description => message
    )
    
    TransactionDataDetail.create_object(
      :transaction_data_id => ta.id,        
      :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_ar_leaf][:code]).id        ,
      :entry_case          => NORMAL_BALANCE[:credit]     ,
      :amount              => remaining_principal,
      :description => message
    )
    ta.confirm
  end
  
    # 
    # def update_group_loan_run_away_amount_receivable
    #   # group_loan = self.group_loan 
    #   # amount = BigDecimal('0')
    #   # group_loan.group_loan_run_away_receivables.each do |x|
    #   #   amount += x.amount_receivable 
    #   # end
    #   # # group_loan.run_away_amount_receivable =  amount 
    #   # group_loan.save
    #   
    #   # create bad_debt_alowance transaction
    #   
    #   
    #   
    #   
    # end
    #  
  
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
