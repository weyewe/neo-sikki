class CreateGroupLoanDefaultPayments < ActiveRecord::Migration
  def change
    create_table :group_loan_default_payments do |t|  
      t.integer :group_loan_membership_id
      t.integer :group_loan_id 
      
      t.decimal :amount_receivable , :default        => 0,  :precision => 12, :scale => 2 
      
      # will be updated on group_loan compulsory_savings deduction 
      t.decimal :compulsory_savings_deduction , :default        => 0,  :precision => 12, :scale => 2 
      t.decimal :remaining_amount_receivable , :default        => 0,  :precision => 12, :scale => 2 

      t.timestamps
    end
  end
end
