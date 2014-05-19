require 'rubygems'
require 'pg'
require 'active_record'
require 'csv'

class AttachEmail2
  
  def extract_amount( value) 
    return BigDecimal('0') if not value.present? 
      
    
    if value.is_a? String
      value = value.gsub(',', '')
      return BigDecimal( value ) 
    elsif value.is_a? Integer
      return BigDecimal( value.to_s)
    end
    
    return BigDecimal('0')
  end
  
  def parse_date( date_string) 
    return nil if not date_string.present?
    # puts "'The date_string: ' :#{date_string}"
    # month/day/year
    
    begin 
      date_array = date_string.split('/').map{|x| x.to_i}
     
      
      datetime = DateTime.new( date_array[2], 
                                date_array[0], 
                                date_array[1], 
                                 0, 
                                 0, 
                                 0,
                    Rational( UTC_OFFSET , 24) )
                  
                  
      return datetime.utc
    rescue Exception => e
      return nil 
    end
  end
  
  def update_fail_member_list(array ) 
    filename = "csvout2.csv"

    CSV.open(filename, 'w') do |csv|
      array.each do |el| 
        csv <<  el 
      end
    end
  end
  
  def clean_savings
    result_array = [] 
    Member.all.each do |member| 
      
      member.total_locked_savings_account = BigDecimal("0")
      member.total_membership_savings = BigDecimal("0")
      member.total_savings_account = BigDecimal("0")
      member.save 

      member.savings_entries.each {|x| x.destroy }
      member.reload 
      
      result_array << [
          member.total_savings_account.to_i, 
          member.total_locked_savings_account.to_i,
          member.total_membership_savings.to_i,
          member.savings_entries.count 
        ]
    end
    
    filename_result = "cleaning_result.csv"

    CSV.open(filename_result, 'w') do |csv|
      result_array.each do |el| 
        csv <<  el 
      end
    end
    
  end

  def generate_csv
    result_array = [] 
    fail_member_id_array = [] 
    
    begin
      filename = "awesome_csv.csv" 
      CSV.open(filename, 'r') do |csv| 
         
        
        csv.each do |x|  
          
          
          # puts "\n"
          # puts "#{x[0]} : #{x[1]}"
          # puts "#{x[0]} : #{x[1]}  => #{extract_amount( x[9] )}  | #{extract_amount( x[10] )} | #{extract_amount( x[11] ) } "
          voluntary_savings_amount =  extract_amount( x[9] ) 
          locked_savings_amount =  extract_amount( x[10] ) 
          membership_savings_amount = extract_amount( x[11] ) 
          # puts "voluntary: #{extract_amount( x[6] )} "
          #  puts "locked: #{extract_amount( x[7] )} "
          #  puts "membership: #{extract_amount( x[8] ) }"
          member  = Member.find_by_id_number( x[0])
          
          if member.nil?
            puts "====> NIL"
            fail_member_id_array << x[0] 
          else
            
            
            voluntary_savings = SavingsEntry.create_adustment_variant_object( {
              :amount                 => voluntary_savings_amount , 
              :direction              => FUND_TRANSFER_DIRECTION[:incoming]  ,
              :member_id              => member.id ,
              :description            => "migration data"
              }, SAVINGS_STATUS[:savings_account] ) 

            # generate training savings
            locked_savings = SavingsEntry.create_adustment_variant_object( {
              :amount                 => locked_savings_amount , 
              :direction              => FUND_TRANSFER_DIRECTION[:incoming]  ,
              :member_id              => member.id ,
              :description            => "migration data"
              }, SAVINGS_STATUS[:locked] )

            # generate membership savings 
            membership_savings = SavingsEntry.create_adustment_variant_object( {
              :amount                 => membership_savings_amount , 
              :direction              => FUND_TRANSFER_DIRECTION[:incoming]  ,
              :member_id              => member.id ,
              :description            => "migration data"
              }, SAVINGS_STATUS[:membership] )

            voluntary_savings.confirm(:confirmed_at => DateTime.now)
            locked_savings.confirm(:confirmed_at => DateTime.now)
            membership_savings.confirm(:confirmed_at => DateTime.now)
            
            member.reload 
            result_array << [
                member.id_number, 
                 member.total_savings_account.to_i       , 
                 member.total_locked_savings_account.to_i, 
                 member.total_membership_savings.to_i
                 
              ]
      
          end
          
          
            
        end
         
         
         
        # update_fail_member_list( fail_member_id_array )
        
      end
    rescue Exception => e
      puts e
    end
    
    filename_result = "porting_result.csv"

    CSV.open(filename_result, 'w') do |csv|
      result_array.each do |el| 
        csv <<  el 
      end
    end
    
    puts "#{fail_member_id_array}"
    
  end
  
  def generate_current_statistic_csv
    result_array = [] 
    Member.all.order("id_number ASC").each do |member|
      # puts "#{member}"
      result_array << [
          member.id_number ,
          member.total_savings_account.to_i       , 
           member.total_locked_savings_account.to_i, 
           member.total_membership_savings.to_i
        ]
    end
    
    filename_result = "current_statistic.csv"

    CSV.open(filename_result, 'w') do |csv|
      result_array.each do |el| 
        csv <<  el 
      end
    end
     
  end
  
  def generate_post_migration_report
    begin
      filename = "awesome_csv.csv" 
    
      result_array = [] 
      fail_member_id_array = [] 
      CSV.open(filename, 'r') do |csv| 
        csv.each do |x| 
          
          # puts "\n"
          # puts "#{x[0]} : #{x[1]}"
          # puts "#{x[0]} : #{x[1]}  => #{extract_amount( x[9] )}  | #{extract_amount( x[10] )} | #{extract_amount( x[11] ) } "
          voluntary_savings_amount =  extract_amount( x[9] ) 
          locked_savings_amount =  extract_amount( x[10] ) 
          membership_savings_amount = extract_amount( x[11] ) 
          # puts "voluntary: #{extract_amount( x[6] )} "
          #  puts "locked: #{extract_amount( x[7] )} "
          #  puts "membership: #{extract_amount( x[8] ) }"
          member  = Member.find_by_id_number( x[0])
        
        
        
        
          if member.nil?
            puts "====> NIL"
            fail_member_id_array << x[0] 
          else
          
            member_voluntary_savings_amount  =  member.total_savings_account
            member_locked_savings_amount     =  member.total_locked_savings_account
            member_membership_savings_amount =  member.total_membership_savings
          
            diff_voluntary_savings_amount     = member_voluntary_savings_amount   - voluntary_savings_amount 
            diff_locked_savings_amount        = member_locked_savings_amount     - locked_savings_amount    
            diff_membership_savings_amount    = member_membership_savings_amount - membership_savings_amount
            
            
            if diff_voluntary_savings_amount.to_i !=  0 || 
                diff_locked_savings_amount != 0 || 
                diff_membership_savings_amount != 0 
                
              puts "member #{member.id_number} is problematic"
            end
            
            result_array << [ 
                              x[0], 
                              x[1],
                              member_voluntary_savings_amount.to_i,
                              member_locked_savings_amount.to_i,
                              member_membership_savings_amount.to_i,
                              diff_voluntary_savings_amount.to_i,
                              diff_locked_savings_amount.to_i,
                              diff_membership_savings_amount.to_i 
                              ]
          end
        
        end

      end
    rescue Exception => e
      puts e
    end
    
    # convert the result set to another csv 
    filename_result = "result_mapping.csv"

    CSV.open(filename_result, 'w') do |csv|
      result_array.each do |el| 
        csv <<  el 
      end
    end
    
    puts "The unknown member: " 
    puts "#{fail_member_id_array} "
    
  end
end


task :clean_savings_2014_16_5 => :environment do
  generate= AttachEmail2.new
  generate.clean_savings
end


task :generate_csv_member_non_ktp_2014_16_5 => :environment do
  generate= AttachEmail2.new
  generate.generate_csv
end

task :generate_current_statistics_2014_16_5 => :environment do
  generate= AttachEmail2.new
  generate.generate_current_statistic_csv
end





task :generate_post_migration_report_2014_16_5 => :environment do
  generate= AttachEmail2.new
  generate.generate_post_migration_report 
end


