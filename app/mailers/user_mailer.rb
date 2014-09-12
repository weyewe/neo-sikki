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
    filename = "#{Rails.root}/public/#{base_filenames}"
    
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
    
    
end

