class CreateDeceasedPrincipalReceivables < ActiveRecord::Migration
  def change
    create_table :deceased_principal_receivables do |t|
      t.integer :member_id
      t.decimal :amount_receivable , :default        => 0,  :precision => 12, :scale => 2 
      
      t.decimal :amount_paid, :default        => 0,  :precision => 12, :scale => 2 
      
      t.boolean :is_closed, :default => false 
      
      t.string :payment_document 
      
      t.timestamps
    end
  end
end
