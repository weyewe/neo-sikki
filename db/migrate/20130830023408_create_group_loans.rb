class CreateGroupLoans < ActiveRecord::Migration
  def change
    create_table :group_loans do |t|
      t.string :name  
      t.integer :number_of_meetings  # meetings is not linked with weekly installment
      t.integer :number_of_collections
      # meeting is education session 
      
      t.boolean :is_started, :default => false 
      
      # not really necessary. can be handled offline. 
      t.boolean :is_loan_disbursement_prepared, :default => false 
      
      t.boolean :is_loan_disbursed, :default => false 
      t.boolean :is_closed, :default => false 
      
      t.integer :group_leader_id 
      
      
      
      t.timestamps
    end
  end
end
