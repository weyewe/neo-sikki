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



task :generate_deceased_gl => :environment do
  
  deceased_list =  DeceasedClearance.all
  total = deceased_list.length
  
  counter = 1 
  
  deceased_list.each do |x|
    puts "deceased #{counter}/#{total}"
    
    AccountingService::Deceased.create_bad_debt_allocation(
        x.group_loan_membership.group_loan, 
        x.member, 
        x.group_loan_membership, 
        x)
    
    counter += 1 
  end
end
