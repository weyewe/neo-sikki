require 'rubygems'
require 'pg'
require 'active_record'
require 'csv'


task :generate_loan_disbursement_gl => :environment do
  
  group_loan_list = GroupLoan.where(
    :is_loan_disbursed => true
  )
  
  total = group_loan_list.length 
  puts "Total: #{total}"
  
  counter = 1 
  group_loan_list.each do |x|
    puts "group_loan #{counter}/#{total}"
    AccountingService::LoanDisbursement.create_loan_disbursement(x ) 
    counter += 1 
  end
  
end
