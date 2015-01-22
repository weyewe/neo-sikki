class CreateMemorials < ActiveRecord::Migration
  def change
    create_table :memorials do |t|
      
      
      t.datetime :transaction_datetime
      t.text :description 

      # debit amount must be equal to credit amount.. ahahaha awesome shite 
      t.boolean :is_confirmed  # can only be confirmed if debit == credit.. hahaha.
      t.string :code 
      
      t.boolean :is_deleted
      t.datetime :deleted_at 
  
      t.timestamps
    end
  end
end
