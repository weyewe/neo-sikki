json.success true 
json.total @total
 

json.savings_entries @objects do |object|
	json.id 								object.id 
	json.member_id 			 object.member_id   
	json.member_name 			 object.member_name
	json.member_id_number 			 object.member_id_number
	
	json.direction 							object.direction
	
	if object.direction == FUND_TRANSFER_DIRECTION[:incoming] 
		json.direction_text				"Penambahan" 
	elsif object.direction == FUND_TRANSFER_DIRECTION[:outgoing]
		json.direction_text				"Penarikan" 
	end
	
	json.amount object.amount
	json.is_confirmed object.is_confirmed
	json.confirmed_at object.confirmed_at 
	
end
