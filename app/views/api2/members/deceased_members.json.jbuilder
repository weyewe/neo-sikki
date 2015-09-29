
json.success true 
json.total @total
json.deceased_members @objects do |object|
	 
    json.name object.name 
    json.id_number object.id_number
    json.id_card_number object.id_card_number
    json.birthday_date  object.birthday_date
    json.deceased_at object.deceased_at 
	
end




 