class CreateCashBankMutations < ActiveRecord::Migration
  def change
    create_table :cash_bank_mutations do |t|
      
      t.integer :source_cash_bank_id
      t.integer :target_cash_bank_id
      t.datetime :mutation_date 
      t.string :description 
      
      t.decimal :amount, :default       => 0, :precision => 14, :scale => 2 # 10^12  10^9 is 1M
       
      t.string :code, :default => false 
      
      t.boolean :is_confirmed, :default => false 
      t.datetime :confirmed_at 
      
      t.boolean :is_deleted, :default => false
      t.datetime :deleted_at 

      t.timestamps
    end
  end
end
