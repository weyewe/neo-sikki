class CreateCollectionGroups < ActiveRecord::Migration
  def change
    create_table :collection_groups do |t|

      t.string :name 
      t.text :description 
      t.integer :branch_id 
      t.integer :user_id   # penanggung jawab yg buat dateng, collect 
      
      t.integer :collection_day  # hari apa colletion nya? senin-jumat 
      t.integer :collection_hour  # slot jam berapa? 
      
      # 08.30, 09.00, 09.30, 10.00, 10.30, 11.00, 11.30, 12.00, 12.30, 13.00, 
      
      
      t.timestamps
    end
  end
end
