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
  
  total = GroupLoan.where(
    :is_loan_disbursed => true ,
    :is_closed => true 
  ).count
   
  count = 1 
  GroupLoan.where(
    :is_loan_disbursed => true ,
    :is_closed => true 
  ).find_each do |group_loan|
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

=begin
{"success":true,"total":1,"group_loans":[{"id":247,"name":"Banteng A 309","number_of_meetings":25,"number_of_collections":25,"total_members_count":9,"group_number":"309","is_started":true,"started_at":"2013-12-11","is_loan_disbursed":true,"disbursed_at":"2013-12-11","is_closed":true,"closed_at":"2014-07-01","is_compulsory_savings_withdrawn":true,"compulsory_savings_withdrawn_at":"2014-07-01","start_fund":"7400000.0","disbursed_group_loan_memberships_count":9,"disbursed_fund":"7400000.0","non_disbursed_fund":"0.0","active_group_loan_memberships_count":9,"compulsory_savings_return_amount":"2950000.0","bad_debt_allowance":"0.0","bad_debt_expense":"0.0","premature_clearance_deposit":"0.0","expected_revenue_from_run_away_member_end_of_cycle_resolution":"0.0","total_compulsory_savings_pre_closure":"2950000.0"}]}
=end
