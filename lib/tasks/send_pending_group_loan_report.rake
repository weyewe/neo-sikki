require 'rubygems'
require 'pg'
require 'active_record'
require 'csv'




task :send_pending_group_loan_report => :environment do
  now = DateTime.now 
  
  # send every wednesday and friday, 9pm.. in gmt + 0 => wednesday 2pm
  #  0 = sunday, 1= monday
  if now.wday == 3 or now.wday == 5
    if now.hour == 14 
      UserMailer.pending_group_loan(["w.yunnal@gmail.com", 
                                      "koperasi.kasih.indonesia@gmail.com", 
                                      "lucyana_siregar@yahoo.com",
                                      "leonardo.kamilius@gmail.com"]).deliver
    else
      puts "wednesday, friday, but not 14pm"
    end
    
  else
    puts "NOt wednesday or friday"
  end
   
  
end
