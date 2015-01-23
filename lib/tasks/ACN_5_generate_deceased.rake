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
    DeceasedClearance.all.each do |x|
      
      
      AccountingService::Deceased.create_bad_debt_allocation(
          x.group_loan_membership.group_loan, 
          member, 
          x.group_loan_membership, 
          x)
    end
   

  end
end



task :generate_deceased_gl => :environment do
  

  generate = AttachEmail.new
  generate.generate_csv
  
end
