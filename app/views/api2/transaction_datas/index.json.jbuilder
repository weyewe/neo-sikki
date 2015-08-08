json.success true 
json.total @total




json.transaction_datas @objects do |object|

	json.id 								object.id 
	json.transaction_source_id 				object.transaction_source_id
	json.transaction_source_type			object.transaction_source_type
	json.description						object.description
	json.amount 							object.amount 
	json.is_contra_transaction				object.is_contra_transaction
	json.code								object.code

 
 

	json.transaction_data_details object.transaction_data_details do |tdd|
		json.entry_case 		tdd.entry_case
		json.account_name		tdd.account.name 
		json.account_code		tdd.account.code 
		json.amount			tdd.amount 
	end
end

  