

task :open_group_loan_report => :environment do
  UserMailer.welcome.deliver
  
end