
json.success true 
json.total @total
json.active_members @objects do |object|
	 
    json.member_name 				object.member.name  
    json.member_id_number 			object.member.id_number
    json.member_id_card_number 		object.member.id_card_number
    json.group_loan_name  			object.group_loan.name
    json.group_loan_group_number 	object.group_loan.group_number 
    json.group_loan_product_principal object.group_loan_product.principal  


	
end




 