class CreateCashMutations < ActiveRecord::Migration
  def change
    create_table :cash_mutations do |t|
      
      t.string :cash_bank_id
      t.string :source_document_type 
      t.integer :source_document_id 
      t.string :source_document_code 
      t.decimal :amount, :default       => 0, :precision => 14, :scale => 2 
      

      t.timestamps
    end
  end
end
