require 'csv'

namespace :report_2019 do
    
    
    task generate_member_duplicate: :environment do
        
        array = []
        
        counter = 0
        Member.find_each do |x| 
            
            total_duplicate = Member.where(:id_card_number => x.id_card_number).count 
            
            array << [
                x.id, 
                x.name,
                x.address, 
                x.id_card_number, 
                total_duplicate
                ] 
            
            counter = counter  +  1 
            if counter %100 == 0 
                puts "current_counter: #{counter.to_s(:delimited)}"
            end
        end
        
        
        branches_file_location = Rails.root.to_s + "/tmp/member_duplicate.csv"
        
        
        CSV.open(branches_file_location, "w") do |csv|
          csv << [
                "internal id",
                "name",
                "Address",  
                "KTP", 
                "total_duplicate_ktp"
                ]
        
          array.each do |x| 
            csv <<  x 
          end
        end

    end
    
end