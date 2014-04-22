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
    # puts "Inside the parse_date"
    # puts "'The date_string: ' :#{date_string}"
    # month/day/year
    # puts "The date_string: #{date_string}"
    
    begin 
      date_array = date_string.split('/').map{|x| x.to_i}
      
      # puts "The date array: #{date_array}"
     
      
      # 11/21/1958  month/day/year 
      datetime = DateTime.new( date_array[2],# year 
                                date_array[0],   # month 
                                date_array[1],  # day 
                                 0, 
                                 0, 
                                 0,
                    Rational( UTC_OFFSET , 24) )
                  
      # puts "The datetime: #{datetime}"            
      return datetime.utc
    rescue Exception => e
      # puts "There is exception"
      puts e 
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
      filename = "update_member_address.csv"
      
      CSV.open(filename, 'r') do |csv| 
         
        fail_member_id_array = [] 
        
        csv.each do |x|
          puts "\n\n"
          # puts "#{x.inspect}"
          # puts "id : #{x[0]}"
          # puts "name : #{x[1]}"
          # puts "ktp_number : #{x[2]}"
          # puts "birthday: #{x[3]}"
          # puts "address: #{x[4]}"
          # puts "rt: #{extract_amount( x[5] ) }"
          # puts "rw: #{extract_amount( x[6] )}"
          # puts "village: #{extract_amount( x[7] )}" 
          
          member = Member.find_by_id_number( x[0] )
          
          if member.nil? 
            puts "member with id_number #{x[0]} is non existant"
          else
            # puts "Inside member update"
            member.id_card_number = x[2]
            member.birthday_date = parse_date( x[3] ) 
            member.address = x[4]
            member.name = x[1]
            member.rt = x[5]
            member.rw  = x[6]
            member.village = x[7]
            member.save 
          end  
          
        end
         
      end
    rescue Exception => e
      puts e
    end
  end
  

end



task :update_and_generate_member_address_data => :environment do
  generate= AttachEmailNew.new
  generate.generate_csv
end
 

