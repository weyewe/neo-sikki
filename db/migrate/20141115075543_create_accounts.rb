class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      
      
      t.string :code  # will be sorted. the smaller the code, the more current it is 
      t.string :name # account name 
      t.integer :group # asset, expense, liability, revenue, and equity
      t.integer :level # level 1 ,2 ,3 ? 
      t.integer :parent_id  # if it is not the root account 
      t.boolean :is_legacy, :default => false 
      t.boolean :is_leaf, :default => false  # direct posting can be made 
      t.boolean :is_cash_bank_account , :default => false  # cash bank account can't be directly modified by memorial
      
      t.string :legacy_code  ## behind the scene, pre assigned
      
      

      t.timestamps
    end
  end
end
