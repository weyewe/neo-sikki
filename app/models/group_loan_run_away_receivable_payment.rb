class GroupLoanRunAwayReceivablePayment < ActiveRecord::Base
  attr_accessible :group_loan_run_away_receivable_id ,
                  :group_loan_weekly_collection_id   ,
                  :group_loan_membership_id          ,
                  :group_loan_id                     ,
                  :amount                            ,
                  :payment_case                      
  
  has_many :transaction_activities, :as => :transaction_source 

  belongs_to :group_loan_membership
  belongs_to :group_loan
  belongs_to :group_loan_weekly_collection
  belongs_to :group_loan_run_away_receivable
  
  after_create :create_transaction_activities 
  
  def create_transaction_activities
    member = group_loan_membership.member 
    
    # Weekly payment 
    TransactionActivity.create :transaction_source_id => self.id, 
                              :transaction_source_type => self.class.to_s,
                              :amount =>  self.amount  ,
                              :direction => FUND_TRANSFER_DIRECTION[:incoming],
                              :member_id => member.id,
                              :fund_case => FUND_TRANSFER_CASE[:cash]
  end
end
