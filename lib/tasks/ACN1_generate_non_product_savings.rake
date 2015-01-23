require 'rubygems'
require 'pg'
require 'active_record'
require 'csv'



task :generate_non_product_savings_gl => :environment do
  

  SavingsEntry.where(
		:savings_status => [
			SAVINGS_STATUS[:savings_account],
      SAVINGS_STATUS[:membership],
      SAVINGS_STATUS[:locked]
		],
		:is_confirmed => true 
	).each do |s_e|
	  multiplier = 0 
	  multiplier = 1 if s_e.direction == FUND_TRANSFER_DIRECTION[:incoming]
    multiplier = -1 if s_e.direction == FUND_TRANSFER_DIRECTION[:outgoing]
	  
	  if s_e.savings_status == SAVINGS_STATUS[:savings_account]
	    AccountingService::IndependentSavings.post_savings_account(s_e, multiplier, s_e.amount  )
    elsif SAVINGS_STATUS[:membership]
      AccountingService::IndependentSavings.post_savings_account(s_e, multiplier, s_e.amount  )
    elsif SAVINGS_STATUS[:locked]
      AccountingService::IndependentSavings.post_savings_account(s_e, multiplier, s_e.amount  )
    end
	  
  end
  
end
