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
    
    GroupLoan.where(
      :is_disbursed => true
    ).each do |x|
      AccountingService::LoanDisbursement.create_loan_disbursement(x ) 
    end
    
   

  end
end



task :generate_loan_disbursement_gl => :environment do
  

  generate = AttachEmail.new
  generate.generate_csv
  
end
