json.success true 
json.total @total
json.group_loans @objects do |object|
	json.id 								object.id 
	json.name 			 			object.name
	json.group_number 			 			object.group_number



	if not object.first_uncollected_weekly_collection.nil? 
		json.outstanding_weekly_collection_id object.first_uncollected_weekly_collection.id


		json.outstanding_weekly_collection_week_number object.first_uncollected_weekly_collection.week_number
	end

 

end

  