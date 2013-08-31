class CreateGroupLoanWeeklyCollections < ActiveRecord::Migration
  def change
    create_table :group_loan_weekly_collections do |t|
      t.integer :group_loan_id 
      t.integer :week_number 
      t.boolean :is_collected, :default => false 
      t.boolean :is_confirmed, :default => false 
      
      t.datetime :collection_datetime   # explicit, has to be selected by the loan officer 
      
      t.datetime :confirmation_datetime # implicit, generated when the admin is confirming loan 

      t.timestamps
    end
  end
end
