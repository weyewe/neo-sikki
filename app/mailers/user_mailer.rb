# UserMailer.notify_new_user_registration( new_object , password    ).deliver

class UserMailer < ActionMailer::Base
  require 'faster_csv'
  
  default from: "from@example.com"

  def welcome 
    content = 'awesome banzai'
    # attachments['text.txt'] = {:mime_type => 'text/plain',
    #    :content => content }
    #  
    
    mail(:to => "admin@11ina.com", :subject => "banzai New account information")
  end
  
  def sales_for_yesterday 
    @from = 'someone@example.com' 
    @recipients = 'w.yunnal@gmail.com' 
    @sent_on = Time.now 
    @yesterday = 1.day.ago 
    @body = { :yesterday => @yesterday } 
    @subject = "Sales Report"
    
    mail(:to => "admin@11ina.com", :subject => "banzai New account information")
  
    # attachment :content_type => "text/csv", :filename => "sales_#{@yesterday.to_date}.csv" do |a| 
    #   a.body = FasterCSV.generate do |csv| 
    #     csv < < (fields = ["artist", "product", "variant", "unit price", "qty sold", "total"]).map {|f| f.titleize } 
    #     # Report.sales_for_date(@yesterday).each do |row| 
    #     #   csv << fields.map {|f| row[f] } 
    #     # end 
    #   end 
    # end 
  end
    
    
end

