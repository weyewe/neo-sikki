require 'rubygems'
require 'pg'
require 'active_record'
require 'csv'
require 'writeexcel'




task :generate_xls_report => :environment do
  
  workbook = WriteExcel.new('kki_xls_report.xls')
  data_array = TransactionData.joins(:transaction_data_details => [:account]).
            order("transaction_datetime ASC").limit(100)
  
  worksheet = workbook.add_worksheet
  
  TRANSACTION_NUMBER_COLUMN = 0
  TRANSACTION_DESCRIPTION = 1 
  TRANSACTION_DATETIME = 2 
  DEBIT_ACCOUNT_NAME = 3
  DEBIT_AMOUNT = 4
  CREDIT_ACCOUNT_NAME = 5
  CREDIT_AMOUNT = 6
  row = 0 

  worksheet.set_column(TRANSACTION_DESCRIPTION, TRANSACTION_DESCRIPTION,  50) # Column  A   width set to 20
  worksheet.set_column(TRANSACTION_DATETIME, TRANSACTION_DATETIME,  25)
  
  worksheet.set_column(DEBIT_ACCOUNT_NAME, DEBIT_ACCOUNT_NAME,  30)
  worksheet.set_column(CREDIT_ACCOUNT_NAME, CREDIT_ACCOUNT_NAME,  30)
  
  worksheet.set_column(DEBIT_AMOUNT, DEBIT_AMOUNT,  20)
  worksheet.set_column(CREDIT_AMOUNT, CREDIT_AMOUNT,  20)

  
  worksheet.write(0, TRANSACTION_NUMBER_COLUMN  , 'NO')
  worksheet.write(0, TRANSACTION_DESCRIPTION  , 'Transaksi')
  worksheet.write(0, TRANSACTION_DATETIME  , 'Tanggal Transaksi')
  worksheet.write(0, DEBIT_ACCOUNT_NAME  , 'Akun Di Debit')
  worksheet.write(0, DEBIT_AMOUNT  , 'Jumlah')
  worksheet.write(0, CREDIT_ACCOUNT_NAME  , 'Akun di kredit')
  worksheet.write(0, CREDIT_AMOUNT  , 'Jumlah')
  
  row += 1
  entry_number  = 1 
  data_array.each do |transaction|
    debit_transaction_array = transaction.transaction_data_details.where(
      :entry_case => NORMAL_BALANCE[:debit]
    )
    
    credit_transaction_array =   transaction.transaction_data_details.where(
      :entry_case => NORMAL_BALANCE[:credit]
    )
    
    worksheet.write(row, TRANSACTION_NUMBER_COLUMN  ,  entry_number )
    worksheet.write(row, TRANSACTION_DESCRIPTION  , transaction.description )
    worksheet.write(row, TRANSACTION_DATETIME  , transaction.transaction_datetime )
    
    counter = 0 
    debit_transaction_array.each do |transaction_data_detail|
      worksheet.write(row + counter, DEBIT_ACCOUNT_NAME  , transaction_data_detail.account.name)
      worksheet.write(row + counter, DEBIT_AMOUNT  , transaction_data_detail.amount )
      counter += 1 
    end
    
    counter = 0 
    credit_transaction_array.each do |transaction_data_detail|
      worksheet.write(row + counter, CREDIT_ACCOUNT_NAME  , transaction_data_detail.account.name)
      worksheet.write(row + counter, CREDIT_AMOUNT  , transaction_data_detail.amount )
      counter += 1 
    end
     
    
    
    length = debit_transaction_array.length
    length = credit_transaction_array.length if credit_transaction_array.length > debit_transaction_array.length

    
    row += length   + 1 
    entry_number += 1
  end
  
  workbook.close
  
end
