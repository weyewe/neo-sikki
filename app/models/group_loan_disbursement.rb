class GroupLoanDisbursement < ActiveRecord::Base
  attr_accessible :group_loan_membership_id
                  
                  
  
  
  
  
  has_many :transaction_activities, :as => :transaction_source 
  has_many :savings_entries, :as => :savings_source 
  
  belongs_to :group_loan_membership
  
  validates_uniqueness_of :group_loan_membership_id 
  
  after_create :create_transaction_activities , :create_initial_compulsory_savings
  
  
  def create_transaction_activities  
    
    
     
    # COMPANY's perspective
    # on group loan disbursement, there are 2 activities: 
    # company disbursed the $$$
    # member pays the admin fee
    
    member = group_loan_membership.member 
    
    # Office disburse $$ to member 
    TransactionActivity.create :transaction_source_id => self.id, 
                              :transaction_source_type => self.class.to_s,
                              :amount => group_loan_membership.group_loan_product.disbursed_principal ,
                              :direction => FUND_TRANSFER_DIRECTION[:outgoing],
                              :member_id => member.id,
                              :fund_case => FUND_TRANSFER_CASE[:cash]
    
    
    # Payment of admin fee 
    TransactionActivity.create :transaction_source_id => self.id, 
                              :transaction_source_type => self.class.to_s,
                              :amount => group_loan_membership.group_loan_product.admin_fee   ,
                              :direction => FUND_DIRECTION[:incoming], 
                              :member_id => member.id,
                              :fund_case => FUND_TRANSFER_CASE[:cash]
                              
    # if initial savings is not 0 
    if group_loan_membership.group_loan_product.initial_savings != BigDecimal('0')
      TransactionActivity.create :transaction_source_id => self.id, 
                                :transaction_source_type => self.class.to_s,
                                :amount => group_loan_membership.group_loan_product.initial_savings   ,
                                :direction => FUND_DIRECTION[:incoming], 
                                :member_id => member.id ,
                                :fund_case => FUND_TRANSFER_CASE[:cash]
    end
  end
  
  def create_initial_compulsory_savings 
    
    if group_loan_membership.group_loan_product.initial_savings != BigDecimal('0')
      SavingsEntry.create_group_loan_disbursement_initial_compulsory_savings( self )
    end
    
  end
  
end
