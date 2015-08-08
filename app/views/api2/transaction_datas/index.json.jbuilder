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

 	
 	source_object  = object.get_source_object

 

 	if source_object.class.to_s == "GroupLoan"
 		json.group_number 		source_object.group_number
 		json.group_name 		source_object.name
 		json.member_id_number		""
 		json.member_name			""
 		json.set_ke					"" 

 	elsif source_object.class.to_s == "GroupLoanWeeklyCollectionVoluntarySavingsEntry"
 		group_loan_membership = source_object.group_loan_membership
 		group_loan_weekly_collection = source_object.group_loan_weekly_collection 
 		member  = group_loan_membership.member
 		group_loan = group_loan_membership.group_loan

 		json.group_number 		group_loan.group_number
 		json.group_name 		group_loan.name
 		json.member_id_number		member.id_number
 		json.member_name			member.name 
 		json.set_ke					group_loan_weekly_collection.week_number

 	elsif source_object.class.to_s == "GroupLoanWeeklyCollection"
 		group_loan = source_object.group_loan 

 		json.group_number 		group_loan.group_number
 		json.group_name 		group_loan.name
 		json.member_id_number		""
 		json.member_name			""
 		json.set_ke					source_object.week_number

	elsif source_object.class.to_s == "DeceasedClearance"
 		member = source_object.member 

 		json.group_number 		""
 		json.group_name 		""
 		json.member_id_number		member.id_number
 		json.member_name			member.name 
 		json.set_ke					""

 	elsif source_object.class.to_s == "GroupLoanPrematureClearancePayment"
 		group_loan_weekly_collection = source_object.group_loan_weekly_collection
 		group_loan = source_object.group_loan
 		member = source_object.group_loan_membership.member

 		json.group_number 		group_loan.group_number
 		json.group_name 		group_loan.name
 		json.member_id_number		member.id_number
 		json.member_name			member.name 
 		json.set_ke					group_loan_weekly_collection.week_number


 	elsif source_object.class.to_s == "SavingsEntry" 
 		member = source_object.member

 		json.group_number 		 ""
 		json.group_name 		 ""
 		json.member_id_number		member.id_number
 		json.member_name			member.name 
 		json.set_ke					""
 		
 	end
 

	json.transaction_data_details object.transaction_data_details do |tdd|
		json.entry_case 		tdd.entry_case
		json.account_name		tdd.account.name 
		json.account_code		tdd.account.code 
		json.amount			tdd.amount 
	end
end

  