# bundle exec rake clean_contra; bundle exec rake migrate_glwc_vse_posting
task :clean_contra => :environment do
	contra_array = [] 
	TransactionData.where(
		:is_contra_transaction => true 
	).find_each {|x| contra_array <<  [x.transaction_source_id , x.transaction_source_type, x.id ]   }

	even_array = [] 
	odd_array = [] 

	counter = 0 
	contra_array.each do |el|
		counter = counter + 1 
		puts "row: #{counter}"
		total = TransactionData.where( :transaction_source_id => el[0], :transaction_source_type => el[1] ).count 

		odd_array << el  if total%2 != 0  
		even_array << el  if total%2 == 0  
	end

	even_array.each do |el|
		TransactionData.where( :transaction_source_id => el[0], :transaction_source_type => el[1] ).each {|td| td.delete_object}
	end

	odd_array.each do |el|
		TransactionData.where( :transaction_source_id => el[0], :transaction_source_type => el[1] ).offset(1).order("id DESC").each {|td| td.delete_object }
	end

end
 
 # TransactionData.where( :code =>  TRANSACTION_DATA_CODE[:group_loan_weekly_collection_voluntary_savings] ).

task :migrate_glwc_vse_posting => :environment  do 
	glwc_vse_id_list = [] 
	TransactionData.where( :code =>  TRANSACTION_DATA_CODE[:group_loan_weekly_collection_voluntary_savings] ).find_each {|td| glwc_vse_id_list << td.transaction_source_id  } 

		

	glwc_id_list = []
	GroupLoanWeeklyCollectionVoluntarySavingsEntry.where(:id => glwc_vse_id_list).find_each {  |glwc_vse|  glwc_id_list << glwc_vse.group_loan_weekly_collection_id } 
		
 	

	# puts gwlc_id_list
	total_glwc = glwc_id_list.uniq.count 
	puts "Total weekly collection : #{total_glwc}"

	counter = 0 
	GroupLoanWeeklyCollection.where(:id => glwc_id_list).find_each do |glwc|
		counter = counter + 1 
		puts "#{counter}/#{total_glwc}"
	    total_voluntary_savings_withdrawal = BigDecimal('0')
	    total_voluntary_savings_addition = BigDecimal('0')

	    total_voluntary_savings_addition = glwc.group_loan_weekly_collection_voluntary_savings_entries.where(
	        :direction => FUND_TRANSFER_DIRECTION[:incoming]
	      ).sum("amount")

	 	total_voluntary_savings_withdrawal = glwc.group_loan_weekly_collection_voluntary_savings_entries.where(
	        :direction => FUND_TRANSFER_DIRECTION[:outgoing]
	      ).sum("amount")

	 	td = TransactionData.where(
	 				:code => TRANSACTION_DATA_CODE[:group_loan_weekly_collection],
	 				:transaction_source_id => glwc.id 
	 			).first

	 	if total_voluntary_savings_addition > BigDecimal("0")
            addition_msg = td.description + " => " + " Total penambahan voluntary savings di weekly collection: #{total_voluntary_savings_addition.to_s}"
            TransactionDataDetail.create_object(
              :transaction_data_id => td.id,        
              :account_id          => Account.find_by_code(ACCOUNT_CODE[:voluntary_savings_leaf][:code]).id      ,
              :entry_case          => NORMAL_BALANCE[:credit]     ,
              :amount              => total_voluntary_savings_addition,
              :description => addition_msg
            )

            TransactionDataDetail.create_object(
              :transaction_data_id => td.id,        
              :account_id          => Account.find_by_code(ACCOUNT_CODE[:main_cash_leaf][:code]).id        ,
              :entry_case          => NORMAL_BALANCE[:debit]     ,
              :amount              => total_voluntary_savings_addition,
              :description => addition_msg
            ) 
	 	end

	 	if total_voluntary_savings_withdrawal > BigDecimal("0")
            withdrawal_msg = td.description + " => " + " Total penarikan voluntary savings di weekly collection: #{total_voluntary_savings_withdrawal.to_s}"
            TransactionDataDetail.create_object(
              :transaction_data_id => td.id,        
              :account_id          => Account.find_by_code(ACCOUNT_CODE[:voluntary_savings_leaf][:code]).id      ,
              :entry_case          => NORMAL_BALANCE[:debit]     ,
              :amount              => total_voluntary_savings_withdrawal,
              :description => withdrawal_msg
            )

            TransactionDataDetail.create_object(
              :transaction_data_id => td.id,        
              :account_id          => Account.find_by_code(ACCOUNT_CODE[:main_cash_leaf][:code]).id        ,
              :entry_case          => NORMAL_BALANCE[:credit]     ,
              :amount              => total_voluntary_savings_withdrawal,
              :description => withdrawal_msg
            ) 
	 	end


	end

	TransactionData.where(:transaction_source_id => glwc_vse_id_list, :transaction_source => "GroupLoanWeeklyCollectionVoluntarySavingsEntry").each do |td|
		td.transaction_data_details.each {|x| x.destroy }

		td.destroy 
	end

end
