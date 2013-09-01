class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      
      t.string :name 
      t.text :address 
      
      t.string :id_number 
      
      t.decimal :total_savings_account , :default        => 0,  :precision => 12, :scale => 2
      
      t.boolean :is_deceased, :default => false
      t.datetime :death_datetime 
      
      t.boolean :is_run_away, :default => false 
      

      t.timestamps
    end
  end
end
