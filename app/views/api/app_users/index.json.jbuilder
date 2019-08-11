
json.success true 
json.total @total
json.users @objects do |object|
	json.id 								object.id  
 
	 
	json.email	object.email
	json.name	object.name
	
	json.role_id object.role_id
	json.role_name object.role.name
	
	if not object.branch_id.nil? 
		json.branch_id object.branch_id
		json.branch_name object.branch.name
		
	else
		json.branch_id  nil 
		json.branch_name nil 
	end

	
	 
	
	
end


