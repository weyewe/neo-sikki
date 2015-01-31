require 'rubygems'
require 'pg'
require 'active_record'
require 'csv'



task :generate_non_product_savings_gl => :environment do
  puts "basic"
  counter = 1 
  all_data_count = SavingsEntry.where(
		:savings_status => [
			SAVINGS_STATUS[:savings_account],
      SAVINGS_STATUS[:membership],
      SAVINGS_STATUS[:locked]
		],
		:is_confirmed => true 
	).count
	
	
  puts "alldata: #{all_data_count}"
  SavingsEntry.where(
		:savings_status => [
			SAVINGS_STATUS[:savings_account],
      SAVINGS_STATUS[:membership],
      SAVINGS_STATUS[:locked]
		],
		:is_confirmed => true 
	).find_each do |s_e|
	 
	  puts "migrate non product savings: #{counter}/#{all_data_count}"
	  multiplier = 0 
	  multiplier = 1 if s_e.direction == FUND_TRANSFER_DIRECTION[:incoming]
    multiplier = -1 if s_e.direction == FUND_TRANSFER_DIRECTION[:outgoing]
	  
	  if s_e.savings_status == SAVINGS_STATUS[:savings_account]
	    AccountingService::IndependentSavings.delay.post_savings_account(s_e, multiplier   )
    elsif SAVINGS_STATUS[:membership]
      AccountingService::IndependentSavings.delay.post_savings_account(s_e, multiplier   )
    elsif SAVINGS_STATUS[:locked]
      AccountingService::IndependentSavings.delay.post_savings_account(s_e, multiplier )
    end
    
    counter += 1 
	  
  end
  
end
