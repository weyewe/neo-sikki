json.success true 
json.total @total
json.group_loans @objects do |object|
	json.id 								object.id 
	json.name 			 object.name   
	json.number_of_meetings 							object.number_of_meetings 
	json.number_of_collections				object.number_of_collections 
end
