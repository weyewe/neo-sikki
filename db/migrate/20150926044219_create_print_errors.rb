class CreatePrintErrors < ActiveRecord::Migration
  def change
    create_table :print_errors do |t|

     
    	t.integer :user_id 
    	t.datetime :saving_date

      
      t.decimal :amount , :default        => 0,  :precision => 10, :scale => 2 # 10^7 == 10 million ( max value )
     
      # The setup deduction 
      t.text :print_status  
      t.text :reason  
       

      t.timestamps
    end
  end
end
