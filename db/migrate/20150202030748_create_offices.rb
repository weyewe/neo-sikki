class CreateOffices < ActiveRecord::Migration
  def change
    create_table :offices do |t|
      t.string :name 
      t.string :code 

      t.timestamps
    end
  end
end
