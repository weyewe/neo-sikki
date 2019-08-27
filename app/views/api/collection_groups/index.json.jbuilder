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
	
	json.collection_day_name   object.collection_day_name 
	json.collection_day        object.collection_day 
	
	json.collection_hour_name   object.collection_hour_name 
	json.collection_hour        object.collection_hour 
	
	
	
end
