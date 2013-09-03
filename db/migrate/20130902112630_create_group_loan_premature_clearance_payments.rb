class CreateGroupLoanPrematureClearancePayments < ActiveRecord::Migration
  def change
    create_table :group_loan_premature_clearance_payments do |t|
      t.integer :group_loan_id
      t.integer :group_loan_membership_id 
      t.integer :group_loan_weekly_collection_id 
      
      
      # the amount is calculated value  => the update 
      # mechanism is kinda fancy. Use group loan default payment
      t.decimal :amount , :default        => 0,  :precision => 12, :scale => 2 
      t.boolean :is_confirmed, :default => false 
      

      t.timestamps
    end
  end
end
