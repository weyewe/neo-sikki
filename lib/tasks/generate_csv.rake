require 'rubygems'
require 'pg'
require 'active_record'
require 'csv'

class AttachEmail

  def generate_csv
    begin
      filename = "csvout.csv"
      members = Member.all
      
      CSV.open(filename, 'w') do |csv|
        csv << ['ID_NUMBER','NAME', 'KTP']
        members.each do |m|
          puts "member #{m.id}"


          next if  m.id_card_number.present?
          # header row
          
          # products.each do |product|
          csv << [m.id_number, m.name , m.id_card_number]
          # end
        end
        
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
