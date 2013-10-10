class CreateDeceasedClearances < ActiveRecord::Migration
  def change
    create_table :deceased_clearances do |t|
      
      # First, mark each deceased clearance whether it is insurance claimable
      
      t.boolean :is_insurance_claimable, :default => false 
      t.datetime :insurance_claimable_declared_at 
      
        # for non insurance claimable deceased clearance.. it can be written off directly. 
        t.boolean :is_written_off, :default => false 
        t.datetime :written_off_at 
      
        # for insurance claimable, on approval, mark the reimbursement detail
        t.boolean :is_insurance_claim_approved, :default => false 
        t.datetime :insurance_claim_approved_at 
        
        t.decimal :principal_return  , :default        => 0,  :precision => 10, :scale => 2
        t.decimal :donation  , :default        => 0,  :precision => 10, :scale => 2
        
      
      t.boolean :is_claim_received, :default => false 
      t.datetime :claim_received_at 
      
      t.boolean :is_donation_disbursed, :default => false 
      t.datetime :donation_disbursed_at 
      
      
      t.integer :member_id 
      
      t.integer :financial_product_id
      t.string :financial_product_type
      
      t.text :description 
      
      
      # amount of compulsory savings to be ported to savings_account
      # it might not be compulsory savings in different group loan. 
      t.decimal :additional_savings_account  , :default        => 0,  :precision => 10, :scale => 2
      

      t.timestamps
    end
  end
end
