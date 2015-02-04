# UserMailer.notify_new_user_registration( new_object , password    ).deliver

class UserMailer < ActionMailer::Base
  require 'csv'
  
  default from: "w.yunnal@gmail.com"

  def welcome 
    content = 'awesome banzai'
    # attachments['text.txt'] = {:mime_type => 'text/plain',
    #    :content => content }
    #  
    
    mail(:to => "w.yunnal@gmail.com", :subject => "banzai New account information") 
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
        
        while current_month < now
          header_array << "#{current_month.month}/#{current_month.year}"
          current_month =  current_month + 1.month 
        end
        
        header_array << "#{now.day}/#{now.month}/#{now.year}"
        csv << header_array
        
        
        
        # content 
        

        # UserMailer.savings_report(8,2014,5,0).deliver
        
        # current month
        # csv << ['MemberID','Name', 'Voluntary Savings Jan', 'Voluntary Savings Feb', 'Voluntary Savings March', 'Voluntary Savings April', 'Voluntary Savings May', 'Voluntary Savings Jun','Voluntary Savings July', 'Voluntary Savings August' ]
        # count = 0 
                
                 Member.includes(:valid_comb_savings_entries).find_each do |member|
                   # count = count + 1
                   #                   break if count == 10
                   current_month = first_savings_entry.confirmed_at.beginning_of_month 
                   
                   
                   
                   member_data = []
                   
                   member_data << member.id_number
                   member_data << member.name 
                   
                   
                   while current_month <= now do 
                     current_month_valid_comb = member.valid_comb_savings_entries.where(
                       :month => current_month.month,
                       :year => current_month.year,
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
  
  def savings_entry_adjustments_report
    base_filename = "adjustments_report_#{DateTime.now.to_s}.csv"
    filename = "#{Rails.root}/public/#{base_filename}"
    
     
    
    begin
      CSV.open(filename, 'w') do |csv|
        
        # header
        header_array = ["MemberId", "Name", "Savings Amount", "Savings Status", "ConfirmationDate"]
       
        csv << header_array
        

        SavingsEntry.joins(:member).where(:is_adjustment => true, :is_confirmed =>true ).order("confirmed_at ASC").find_each do |savings_entry|
          puts "x"
          
          savings_data = []
          savings_data << savings_entry.member.id_number
          savings_data << savings_entry.member.name 
          savings_data << savings_entry.amount
          
           
          
          savings_status_text = "" 
          if savings_entry.savings_status == SAVINGS_STATUS[:savings_account]
            savings_status_text = "Sukarela"
          elsif savings_entry.savings_status == SAVINGS_STATUS[:membership]
            savings_status_text = "Keanggotaan"
          elsif savings_entry.savings_status == SAVINGS_STATUS[:locked]
            savings_status_text = "Locked"
          end
          
          savings_data << savings_status_text
          savings_data << savings_entry.confirmed_at.to_s
          
           
          csv  << savings_data


        end

      
      end
    rescue Exception => e
      puts e
    end
    
    
    attachments[ "#{base_filename}"] = File.read(filename )
    mail(:to => "admin@11ina.com", :subject => "Adjustment")
  end
  
  def pending_group_loan(email)
    base_filename = "pending_group_loan_#{DateTime.now.to_s}.csv"
    filename = "#{Rails.root}/public/#{base_filename}"
    
    puts "pending group loan"
     
    
    begin
      CSV.open(filename, 'w') do |csv|
        
        # header
        
        header_array = [
            "Group No",
            "Nama Kelompok",
            "Disbursement Date",
            "Jumlah Anggota Aktif",
            "Jumlah Minggu Setoran",
            "Jumlah Minggu Terbayar",
            "Last Payment Date",
            "Jumlah Setoran Berikutnya"
          ]
          
        csv << header_array
        puts "after header array"
        
        
        today = DateTime.now
        end_of_week = today.end_of_week
        list_of_group_loan_id = GroupLoanWeeklyCollection.where{
          ( is_collected.eq false) & 
          ( tentative_collection_date.lte end_of_week)
        } .map{|x| x.group_loan_id}

        list_of_group_loan_id.uniq!
        
        puts "after extracting problematic group loan id"
        @total_pending = 0 
        GroupLoan.includes(:group_loan_memberships, :group_loan_weekly_collections).where( :id => list_of_group_loan_id).order("disbursed_at ASC").each do |group_loan|
          @total_pending += 1
          last_collected = group_loan.group_loan_weekly_collections.where(:is_collected => true, :is_confirmed => true ).order("id ASC").last

          collected_at = nil
          collected_at = last_collected.collected_at if not last_collected.nil?

          next_collection_amount = BigDecimal("0")
          next_collection = group_loan.group_loan_weekly_collections.where(:is_collected => false, :is_confirmed => false ).order("id ASC").first

          next_collection_amount = next_collection.amount_receivable if not next_collection.nil? 
          # puts "before result"
          result = [
              group_loan.group_number,
              group_loan.name, 
              group_loan.disbursed_at, 
              group_loan.active_group_loan_memberships.count , 
              group_loan.number_of_collections,
              group_loan.group_loan_weekly_collections.where(:is_collected => true, :is_confirmed => true ).count ,
              collected_at,
              next_collection_amount
            ]
            # puts "After result"
          csv <<  result
          
        end
      end
    rescue Exception => e
      puts e
    end
    
    
    attachments[ "#{base_filename}"] = File.read(filename )
    mail(:to => email, :subject => "Pending Group Loan #{DateTime.now}")
  end
  
    
    
end

