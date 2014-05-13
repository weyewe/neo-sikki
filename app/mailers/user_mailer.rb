# UserMailer.notify_new_user_registration( new_object , password    ).deliver

class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def welcome 
    some_string = 'awesome banzai'
    attachments['text.txt'] = {:mime_type => 'text/plain',
      :content => some_string }
      mail(:to => "w.yunnal@gmail.com", :subject => "New account information")
  end



  def sales_for_yesterday 
    
    require 'FasterCSV'
    @from = 'someone@example.com' 
    @recipients = 'w.yunnal@gmail.com' 
    @sent_on = Time.now 
    @yesterday = 1.day.ago 
    @body = { :yesterday => @yesterday } 
    @subject = "Sales Report"

# attachments['filename.jpg'] = File.read('/path/to/filename.jpg')

    attachments "text/plain" do |a|
      a.filename = "test.txt" 
      a.body     = File.read(RAILS_ROOT + "/public/test.txt")
    end


    # attachment :content_type => "text/csv", 
    # :filename => "sales_#{@yesterday.to_date}.csv" do |a| 
    #   a.body = FasterCSV.generate do |csv| 
    #     csv << (fields = ["artist", "product", "variant", "unit price", "qty sold", "total"]).
    #     map {|f| f.titleize } 
    # 
    # 
    #     csv << [ 'willy', 'awesome', 'banzai', '500', '50', '500500']
    #    
    #   end 
    # end 
  end 
end

