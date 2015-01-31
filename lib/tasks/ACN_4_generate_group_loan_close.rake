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

    

  def generate_csv
    
    
    
   

  end
end



task :generate_loan_close_gl => :environment do
  
  group_loan_list = GroupLoan.where(
    :is_loan_disbursed => true ,
    :is_closed => true 
  )
  
  total = group_loan_list.length 
  count = 1 
  group_loan_list.each do |group_loan|
    puts "group_loan #{count}/ #{ total}"
    # port from compulsory savings to transient 
    total_compulsory_savings = BigDecimal("0")
    
    group_loan.group_loan_weekly_collections.each do |x|
      x.active_group_loan_memberships.each do |x|
        total_compulsory_savings += x.group_loan_product.compulsory_savings 
      end
    end
    # only deceased and premature_clearance
    
    # now, the total compulsory savings is collected.. to be ported to the transient
    AccountingService::GroupLoanClosingPortCompulsorySavingsDepositTransient.delay.port_deposit_and_compulsory_savings_to_transient_account(
              group_loan, 
                total_compulsory_savings, BigDecimal("0"))
                
    if group_loan.is_compulsory_savings_withdrawn?
      AccountingService::GroupLoanClosingWithdrawCompulsorySavingsDeposit.delay.compulsory_savings_and_deposit_return(
            group_loan, 
            total_compulsory_savings) 
    end
    
    count += 1 
  end
  
end
