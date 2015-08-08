class Api2::TransactionDatasController < Api2::BaseReportApiController



  # def index
    
  #   if params[:print_report].present?
  #   	start_date =  parse_date( params[:start_date] )
	 #   	end_date =  parse_date( params[:end_date] ) 




	 #   	@objects = TransactionData.includes(:transaction_data_details => [:account]).where{
	 #   		( is_confirmed.eq true )  & 
	 #   		(transaction_datetime.gte start_date) & 
  #      		( transaction_datetime.lt end_date )
	 #   	}.page(params[:page]).per(params[:limit]).
	 #   	order("transaction_datetime ASC")

	 #   	@total = TransactionData.includes(:transaction_data_details => [:account]).where{
	 #   		( is_confirmed.eq true )  & 
	 #   		(transaction_datetime.gte start_date) & 
  #      		( transaction_datetime.lt end_date )
	 #   	}.count 

  #   end
  # end

# worksheet.add_cell(1,0, "Date")
# worksheet.add_cell(1,1, "No")
# worksheet.add_cell(1,2, "Transaction Type")
# worksheet.add_cell(1,3, "Cash in / Cash out/ General Jurnal")
# worksheet.add_cell(1,4, "Group Number")
# worksheet.add_cell(1,5, "Group Name")
# worksheet.add_cell(1,6, "Member ID number")
# worksheet.add_cell(1,7, "Member's Name")
# worksheet.add_cell(1,8, "Set ke")


# worksheet.add_cell(1,9, "Account")
# worksheet.add_cell(1,10, "Amount")
# worksheet.add_cell(1,11, "Account")
# worksheet.add_cell(1,12, "Amount") 

 


   def index
 
		start_date =  parse_date( params[:start_date] ) 

		beginning_of_day = start_date.beginning_of_day
		end_of_day  = start_date.end_of_day


		transaction_source_type_list  =["GroupLoan", 
							"GroupLoanWeeklyCollectionVoluntarySavingsEntry", 
							"GroupLoanWeeklyCollection", 
							"DeceasedClearance", "GroupLoanPrematureClearancePayment", 
							"SavingsEntry"]


		query  = TransactionData.includes(:transaction_data_details => [:account]).where{
			( is_confirmed.eq true )  & 
			# ( transaction_source_type.in transaction_source_type_list) & 
			# (transaction_datetime.gte beginning_of_day) & 
			( transaction_datetime.lt end_of_day )
		}.page(params[:page]).per(params[:limit]).
		order("id ASC")


		@objects = query.page(params[:page]).per(params[:limit])  

		@total =  query.count 
 
  end



end