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
      
      
      
      # if there is member running away, do this shite. 
      # why do we need it? Won't it all be encompassed inside the default_payment? 
      
      # fuck it.. just leave it as it is.. I can't recall why it was coded 
      t.decimal :run_away_amount_receivable, :default       => 0, :precision => 9, :scale => 2
      t.decimal :run_away_amount_received , :default       => 0, :precision => 9, :scale => 2
      
      
      t.timestamps
    end
  end
end
