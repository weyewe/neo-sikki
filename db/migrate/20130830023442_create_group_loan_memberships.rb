class CreateGroupLoanMemberships < ActiveRecord::Migration
  def change
    create_table :group_loan_memberships do |t|
      t.integer :group_loan_id
      t.integer :group_loan_product_id 
      t.integer :member_id 
      
      t.boolean :is_active , :default => true 
      t.integer :deactivation_case # GROUP_LOAN_DEACTIVATION_CASE
      
      t.decimal :total_compulsory_savings  , :default        => 0,  :precision => 9, :scale => 2

      t.timestamps
    end
  end
end
