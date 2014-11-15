class CreateCashBanks < ActiveRecord::Migration
  def change
    create_table :cash_banks do |t|
 
      
      t.string :name
      t.string :description
      t.decimal :amount, :default       => 0, :precision => 14, :scale => 2 # 10^12  10^9 is 1M
      
      t.boolean :status  # bank, cashier, or petty cash
      
   
      
      
      
      t.timestamps
    end
  end
end
