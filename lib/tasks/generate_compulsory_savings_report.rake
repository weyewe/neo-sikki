

task :generate_compulsory_savings => :environment do
  filename = "available_group_loan_report.csv"

	 
  incoming = SavingsEntry.where{
  	( is_confirmed.eq true  ) & 
  	(confirmed_at.lt end_of_year_2015) & 
  	( confirmed_at.gte end_of_year_2014 ) & 
  	( savings_status.eq  SAVINGS_STATUS[:savings_account] ) & 
  	( direction.eq FUND_TRANSFER_DIRECTION[:incoming]) 
  }.sum("amount")

  outgoing = SavingsEntry.where{
  	( is_confirmed.eq true  ) & 
  	(confirmed_at.lt end_of_year_2015) & 
  	( confirmed_at.gte end_of_year_2014 ) & 
  	( savings_status.eq SAVINGS_STATUS[:savings_account]) & 
  	( direction.eq FUND_TRANSFER_DIRECTION[:outgoing]) 
  }.sum("amount")

  diff = outgoing - incoming 


  
end