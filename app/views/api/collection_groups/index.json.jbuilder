json.success true 
json.total @total
json.collection_groups @objects do |object|
 

	json.id 		object.id 
	json.name		object.name 
	json.description		object.description 
	
	
	json.branch_id		object.branch_id
	json.branch_name	object.branch.name 
	
	
	json.user_id		object.user_id
	json.user_name		object.user.name
	
	
	
end
