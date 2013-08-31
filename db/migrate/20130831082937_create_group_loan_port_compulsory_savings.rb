class CreateGroupLoanPortCompulsorySavings < ActiveRecord::Migration
  def change
    create_table :group_loan_port_compulsory_savings do |t|
      t.integer :group_loan_id
      t.integer :group_loan_membership_id
      t.integer :member_id
      

      t.timestamps
    end
  end
end
