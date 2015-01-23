require 'rubygems'
require 'pg'
require 'active_record'
require 'csv'

class AttachEmail

  
  def create_csv(array ) 
    filename = "non_product_linked_savings.csv"

    CSV.open(filename, 'w') do |csv|
      array.each do |el| 
        csv <<  el 
      end
    end
  end

=begin
Column:
1. savings_status
2. amount 
3. direction (in / out?)
4. Member
=end

  def generate_csv
    
    SavingsEntry.where(
  		:savings_status => [
  			SAVINGS_STATUS[:savings_account],
        SAVINGS_STATUS[:membership],
        SAVINGS_STATUS[:locked]
  		],
  		:is_confirmed => true 
  	).each do |s_e|
  	  multiplier = 0 
  	  multiplier = 1 if self.direction == FUND_TRANSFER_DIRECTION[:incoming]
      multiplier = -1 if self.direction == FUND_TRANSFER_DIRECTION[:outgoing]
  	  
  	  if s_e.savings_status == SAVINGS_STATUS[:savings_account]
  	    AccountingService::IndependentSavings.post_savings_account(s_e, multiplier, s_e.amount  )
	    elsif SAVINGS_STATUS[:membership]
	      AccountingService::IndependentSavings.post_savings_account(s_e, multiplier, s_e.amount  )
      elsif SAVINGS_STATUS[:locked]
        AccountingService::IndependentSavings.post_savings_account(s_e, multiplier, s_e.amount  )
      end
  	  
	  end
    
   

  end
end



task :generate_non_product_savings_gl => :environment do
  

  generate= AttachEmail.new
  generate.generate_csv
  
end
