json.success true 
json.total @total
json.members @objects do |object|
	json.id 								object.id 
	json.id_number 			 			object.id_number
	json.name 			 			object.name


end

  