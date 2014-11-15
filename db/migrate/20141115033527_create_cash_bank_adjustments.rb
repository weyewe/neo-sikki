class CreateCashBankAdjustments < ActiveRecord::Migration
  def change
    create_table :cash_bank_adjustments do |t|
      
       
      
      t.string :cash_bank_id
      t.datetime :adjustment_date
      t.string :code 
      t.decimal :amount, :default       => 0, :precision => 14, :scale => 2 # 10^12  10^9 is 1M
       
      t.boolean :is_confirmed, :default => false 
      t.datetime :confirmed_at, :default => false 
      
      t.boolean :is_deleted, :default => false
      t.datetime :deleted_at 
    
      

      t.timestamps
    end
  end
end
