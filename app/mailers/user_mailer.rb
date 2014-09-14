# UserMailer.notify_new_user_registration( new_object , password    ).deliver

class UserMailer < ActionMailer::Base
  require 'csv'
  
  default from: "from@example.com"

  def welcome 
    content = 'awesome banzai'
    # attachments['text.txt'] = {:mime_type => 'text/plain',
    #    :content => content }
    #  
    
    mail(:to => "admin@11ina.com", :subject => "banzai New account information")
  end
  
  def sales_for_yesterday 
    
    base_filename = "awesome.csv"
    filename = "#{Rails.root}/public/#{base_filename}"
    
    begin
      CSV.open(filename, 'w') do |csv|
        csv << ['Report']
        csv << ['Name','Product', 'Item Count']
        # products.each do |product|
        #   csv << [user_name, product.title,product.count]
        # end
      end
    rescue Exception => e
      puts e
    end
    
    
    attachments[ "#{base_filename}"] = File.read(filename )
    mail(:to => "admin@11ina.com", :subject => "Registered")
  end
  
  def savings_report( month, year, number_of_months) 
    
    base_filename = "savings_report_#{month}_#{year}.csv"
    filename = "#{Rails.root}/public/#{base_filename}"
    
    begin
      CSV.open(filename, 'w') do |csv|
        
        # how can we do this? 
        # 1. we have the latest voluntary savings data per member
        # 2. in a given month, extract the voluntary savings mutation. 
        #    add the  inverse diff to the current balance. we will get the net total savings at 
        # the end of previous month
        # 3. 
        
        
        # current month
        csv << ['MemberID','Name', 'Voluntary Savings Jan', 'Voluntary Savings Feb', 'Voluntary Savings March', 'Voluntary Savings April', 'Voluntary Savings May', 'Voluntary Savings Jun','Voluntary Savings July', 'Voluntary Savings August' ]
        Member.all.each do |x|
          csv 
        end
      end
    rescue Exception => e
      puts e
    end
    
    
    attachments[ "#{base_filename}"] = File.read(filename )
    mail(:to => "admin@11ina.com", :subject => "Registered")
  end
  
    
    
end

