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
 
 

