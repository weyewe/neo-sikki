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
  
  def savings_report( month, year, number_of_months, selected_savings_status) 
    
    base_filename = "savings_report_#{month}_#{year}.csv"
    filename = "#{Rails.root}/public/#{base_filename}"
    
    
    first_savings_entry =  SavingsEntry.where(:is_confirmed => true, :savings_status => selected_savings_status ).order("confirmed_at ASC").first 
    beginning_of_month =  first_savings_entry.confirmed_at.beginning_of_month
    now = DateTime.now
    
    
    begin
      CSV.open(filename, 'w') do |csv|
        
        # header
        header_array = ["MemberId", "Name"]
        current_month = beginning_of_month
        
        while beginning_of_month < now
          header_array << "#{beginning_of_month.month}/#{beginning_of_month.year}"
          current_month =  current_month + 1.month 
        end
        
        header_array << "#{now.month}/#{now.year}"
        
        
        
        # content 
        

        
        
        # current month
        # csv << ['MemberID','Name', 'Voluntary Savings Jan', 'Voluntary Savings Feb', 'Voluntary Savings March', 'Voluntary Savings April', 'Voluntary Savings May', 'Voluntary Savings Jun','Voluntary Savings July', 'Voluntary Savings August' ]
        Member.find_each do |member|
          current_month = first_savings_entry.confirmed_at.beginning_of_month 
          
          
          
          member_data = []
          
          member_data << member.id_number
          member_data << member.name 
          
          
          while current_month <= now do 
            current_month_valid_comb = ValidCombSavingsEntry.where(
              :month => current.month,
              :year => current.year,
              :member_id => member.id 
            ).first

            if current_month_valid_comb.nil?
              member_data << BigDecimal("0")
            else
              member_data << current_month_valid_comb.amount 
            end

            current_month = current_month + 1.month
          end
          
          member_data << member.total_savings_account
          csv  << member_data
          
          
        end
      end
    rescue Exception => e
      puts e
    end
    
    
    attachments[ "#{base_filename}"] = File.read(filename )
    mail(:to => "admin@11ina.com", :subject => "Registered")
  end
  
    
    
end

