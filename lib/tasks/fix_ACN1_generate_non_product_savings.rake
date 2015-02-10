require 'rubygems'
require 'pg'
require 'active_record'
require 'csv'


=begin
savings_status_array = [
	SAVINGS_STATUS[:savings_account],
  SAVINGS_STATUS[:membership],
  SAVINGS_STATUS[:locked]
]
SavingsEntry.where{

  ( savings_status.in  savings_status_array ) & 
	( is_confirmed.eq true ) & 
	( confirmed_at.eq nil ) & 
	( savings_source_id.eq nil )

}.count


(
	:savings_status => [
		SAVINGS_STATUS[:savings_account],
    SAVINGS_STATUS[:membership],
    SAVINGS_STATUS[:locked]
	],
	:is_confirmed => true 
)
=end


task :fix_generate_non_product_savings_gl => :environment do
  
  transaction_data_array = [
      TRANSACTION_DATA_CODE[:locked_savings_account],
      TRANSACTION_DATA_CODE[:membership_savings_account],
      TRANSACTION_DATA_CODE[:savings_account]
    ]
     
  
  transaction_data_id_list = TransactionData.where(:code => transaction_data_array).map{|x| x.id }
  TransactionData.where(:id =>transaction_data_id_list ).destroy_all 
  TransactionDataDetail.where(:transaction_data_id => transaction_data_id_list).destroy_all 
  
  
  
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
    elsif s_e.savings_status ==  SAVINGS_STATUS[:membership]
      AccountingService::IndependentSavings.delay.post_membership_savings_account(s_e, multiplier   )
    elsif s_e.savings_status ==  SAVINGS_STATUS[:locked]
      AccountingService::IndependentSavings.delay.post_locked_savings_account(s_e, multiplier )
    end
    
    counter += 1 
	  
  end
  
end
