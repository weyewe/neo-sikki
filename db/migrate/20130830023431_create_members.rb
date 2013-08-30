class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :name 
      t.integer :identification_number 
      t.text :address 
      

      t.timestamps
    end
  end
end
