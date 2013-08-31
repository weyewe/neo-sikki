class GroupLoanWeeklyPayment < ActiveRecord::Base
  attr_accessible :group_loan_membership_id, :group_loan_id, :group_loan_weekly_collection_id
  
  has_many :transaction_activities, :as => :transaction_source 
  has_many :savings_entries, :as => :savings_source
  
  belongs_to :group_loan_membership
  belongs_to :group_loan
  belongs_to :group_loan_weekly_collection 
  
  after_create :create_transaction_activities , :create_compulsory_savings
  
  def create_transaction_activities  
    
     
    member = group_loan_membership.member 
    
    # Weekly payment 
    TransactionActivity.create :transaction_source_id => self.id, 
                              :transaction_source_type => self.class.to_s,
                              :amount => group_loan_membership.group_loan_product.weekly_payment_amount ,
                              :direction => FUND_TRANSFER_DIRECTION[:incoming],
                              :member_id => member.id,
                              :fund_case => FUND_TRANSFER_CASE[:cash]
     
  end
  
  def create_compulsory_savings 
    
    if group_loan_membership.group_loan_product.compulsory_savings != BigDecimal('0')
      SavingsEntry.create_weekly_payment_compulsory_savings( self )
    end
    
  end
end
