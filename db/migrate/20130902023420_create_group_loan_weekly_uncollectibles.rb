class CreateGroupLoanWeeklyUncollectibles < ActiveRecord::Migration
  def change
    create_table :group_loan_weekly_uncollectibles do |t|
      t.integer :group_loan_weekly_collection_id 
      t.integer :group_loan_membership_id 
      t.integer :group_loan_id 
      
      t.decimal :amount , :default        => 0,  :precision => 12, :scale => 2 

      t.timestamps
    end
  end
end
