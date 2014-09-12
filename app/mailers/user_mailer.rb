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
    attachments["rails.png"] = File.read("#{Rails.root}/public/robots.txt")
    mail(:to => "admin@11ina.com", :subject => "Registered")
  end
    
    
end

