class CreateGroupLoanRunAwayReceivablePayments < ActiveRecord::Migration
  def change
    create_table :group_loan_run_away_receivable_payments do |t|
      t.integer :group_loan_run_away_receivable_id 
      t.integer :group_loan_weekly_collection_id 
      t.integer :group_loan_membership_id 
      t.integer :group_loan_id 
      
      t.decimal :amount , :default        => 0,  :precision => 12, :scale => 2 
      
      t.integer :payment_case   # GROUP_LOAN_RUN_AWAY_RECEIVABLE_PAYMENT_CASE
      
      
      
      # this payment can be done in the beginning or the end of the group loan cycle. 
      # if it is done at the end, the payment_case is 
      # GROUP_LOAN_RUN_AWAY_PAYMENT_CASE[:end_of_cycle]
      
      
      
      # amount:  includes the interest, principal and  compulsory savings. 
      # will go to the company's profit directly. not added 
      # On payment:
      # 1. deduct loan portfolio
      # 2. deduct interest receivable 
      # 3. add extra_revenue 
      
      
=begin
  Payment Case:
  1. weekly
  2. end_of_cycle
  3. excess_payment 
  
  On member run away payment collection: 
    recover the loan principal
    recover the interest receivable
    If there is any excess $$, use it to add extra_revenue 
=end
      
      
      t.timestamps
    end
  end
end
