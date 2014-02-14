require 'rubygems'
require 'pg'
require 'active_record'
require 'csv'

class AttachEmailNew
  
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
    filename = "csvout.csv"

    CSV.open(filename, 'w') do |csv|
      array.each do |el| 
        csv <<  el 
      end
    end
  end

  def generate_csv
    begin
      filename = "try_port_2_2014.csv"
      
      CSV.open(filename, 'r') do |csv| 
         
        fail_member_id_array = [] 
        
        csv.each do |x|
          puts "\n\n"
          # puts "#{x.inspect}"
          puts "id : #{x[0]}"
          puts "name : #{x[1]}"
          puts "ktp_number : #{x[2]}"
          puts "birthday: #{x[3]}"
          puts "address: #{x[4]}"
          puts "compulsory_savings: #{extract_amount( x[5] ) }"
          puts "voluntary_savings: #{extract_amount( x[6] )}"
          puts "training_savings: #{extract_amount( x[7] )}"
          puts "membership_savings: #{extract_amount( x[8] )}"
          
          member = Member.find_by_id_number( x[0] )
          
          if member.nil?
            member = Member.create_object(
              :name           => x[1], 
              :address        => x[4], 
              :id_number      =>  x[0], 
              :id_card_number => x[2] , # KTP 
              :birthday_date  => parse_date( x[3] ) ,
              :is_data_complete =>  false
            )
          
            fail_member_id_array << x[0]  if member.errors.size != 0 
          else
            # Flush the savings data
            
            

            member.total_savings_account = BigDecimal('0')
            member.total_membership_savings = BigDecimal('0')
            member.total_locked_savings_account = BigDecimal('0')
            member.save 
            
            member.savings_entries.where(:savings_status => [
                SAVINGS_STATUS[:savings_account],
                SAVINGS_STATUS[:membership],
                SAVINGS_STATUS[:locked]
              ]).each {|x| x.destroy }
          end  
          
          # generate voluntary savings
          voluntary_savings = SavingsEntry.create_adustment_variant_object( {
            :amount                 => extract_amount( x[6] ) , 
            :direction              => FUND_TRANSFER_DIRECTION[:incoming]  ,
            :member_id              => member.id ,
            :description            => "migration data"
          }, SAVINGS_STATUS[:savings_account] ) 
          
          # generate training savings
          locked_savings = SavingsEntry.create_adustment_variant_object( {
            :amount                 => extract_amount( x[7] ) , 
            :direction              => FUND_TRANSFER_DIRECTION[:incoming]  ,
            :member_id              => member.id ,
            :description            => "migration data"
          }, SAVINGS_STATUS[:locked] )
          
          # generate membership savings 
          membership_savings = SavingsEntry.create_adustment_variant_object( {
            :amount                 => extract_amount( x[8] ) , 
            :direction              => FUND_TRANSFER_DIRECTION[:incoming]  ,
            :member_id              => member.id ,
            :description            => "migration data"
          }, SAVINGS_STATUS[:membership] )
          
          voluntary_savings.confirm(:confirmed_at => DateTime.now)
          locked_savings.confirm(:confirmed_at => DateTime.now)
          membership_savings.confirm(:confirmed_at => DateTime.now)
           
        end
         
         
         
        update_fail_member_list( fail_member_id_array )
        
      end
    rescue Exception => e
      puts e
    end
  end
  
  def generate_csv_migration_report
    begin
      filename = "MigrationReport.csv"
      read_from =  "try_port_2_2014.csv"
      
      counter = 0 
      # non_submitted_counter = 0
      # non_finished_counter = 0 
      CSV.open(filename, 'w') do |csv_write| 
        
        # puts "voluntary_savings: #{extract_amount( x[6] )}"
        # puts "training_savings: #{extract_amount( x[7] )}"
        # puts "membership_savings: #{extract_amount( x[8] )}"
        # 
        # 
        csv_write << ["ID_Number","Name", "diff voluntary savings", "diff training savings", "diff membership_savings"  ]

        CSV.open(read_from, 'r') do |csv| 
          csv.each do |x|
            stated_voluntary_savings  = extract_amount( x[6] )
            stated_training_savings   =  extract_amount( x[7] )
            stated_membership_savings =  extract_amount( x[8] )
            
            member = Member.find_by_id_number x[0]
            
            if member.nil?
              puts "The one with id #{x[0]} is not migrated"
              
              array = []
              array << x[0]
              array << "NOT MIGRATED"
              array << 'xx'
              array <<  'xx'
              array << 'xx'
              csv_write << array
            else
              
              diff_voluntary_savings  = member.total_savings_account     - stated_voluntary_savings
              diff_training_savings   = member.total_locked_savings_account - stated_training_savings
              diff_membership_savings = member.total_membership_savings - stated_membership_savings
              
              
              zero = BigDecimal('0')
              
              if diff_voluntary_savings != zero || 
                  diff_training_savings != zero ||
                  diff_membership_savings != zero 
                puts "The one with id #{x[0]} has wrong migration"
              end
              array = []
              array << member.id_number
              array << member.name 
              array << diff_voluntary_savings.to_s
              array << diff_training_savings.to_s
              array << diff_membership_savings.to_s
              csv_write << array
            end
            
            
            
              
          end
        end
      end
    rescue Exception => e
      puts e
    end
  end
end



task :update_and_generate_savings_data => :environment do
  generate= AttachEmailNew.new
  generate.generate_csv
  
  generate.generate_csv_migration_report
end

task :generate_migration_report => :environment do
  generate= AttachEmailNew.new
  
  generate.generate_csv_migration_report
end


