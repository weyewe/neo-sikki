require 'rubygems'
require 'pg'
require 'active_record'
require 'csv'

class AttachEmail
  
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
    date_array = date_string.split('/').map{|x| x.to_i}
     
      
    datetime = DateTime.new( date_array[2], 
                              date_array[0], 
                              date_array[1], 
                               0, 
                               0, 
                               0,
                  Rational( UTC_OFFSET , 24) )
                  
                  
    return datetime.utc
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
      filename = "try_port.csv"
      
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
          
          
          member = Member.create_object(
            :name           => x[1], 
            :address        => x[4], 
            :id_number      =>  x[0], 
            :id_card_number => x[2] , # KTP 
            :birthday_date  => parse_date( x[3] ) ,
            :is_data_complete =>  false
          )
          
          fail_member_id_array << x[0]  if member.errors.size != 0 
            
          
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
end



task :generate_csv_member_non_ktp => :environment do
  generate= AttachEmail.new
  generate.generate_csv
  
end
