

task :available_group_loan_report => :environment do
  filename = "available_group_loan_report.csv"

  CSV.open(filename, 'w') do |csv|
    GroupLoan.includes(:group_loan_memberships).all.each do |x|
      if not x.nil?
        csv << [ x.name, x.group_number,  x.number_of_meetings, x.group_loan_memberships.count  ]  
      end
    end
 
  end
  
end