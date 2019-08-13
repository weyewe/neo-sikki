require 'csv'

namespace :improvement_2019 do
    
    
    task setup_mods: :environment do
        puts "hello biatchh"
    end


    task pair_user_to_branch: :environment do
        branches_file = File.read("#{Rails.root}/lib/data/seeds/branches.csv")
        branches = CSV.parse(branches_file, headers: true)
        
        
        branches.each do |row| 
            # puts row 
            
            branch = Branch.create_object(
                :name         => row['nama'],
                :description  => row['deskripsi'],
                :address      => row['alamat'],
                :code         => row['code']      
            )
        end
   
    end
    
    
    task create_collection_group_to_branch: :environment do
        collection_groups_file = File.read("#{Rails.root}/lib/data/seeds/collection_groups.csv")
        collection_groups = CSV.parse(collection_groups_file, headers: true)
        
        
        
        payment_day_list = [] 
        PAYMENT_DAY.each {|key,value| payment_day_list << value } 
        
        payment_hour_list = [] 
        PAYMENT_HOUR.each {|key,value| payment_hour_list << value} 
        
        collection_groups.each do |row| 
            # puts row 
            
            branch = Branch.find_by_code row['branch_code']
            
            if branch.nil?
                puts "FUCKKK THE branch is nil!!!!"
                next
            end
            
            
            # dari random 
            selected_user_id = ''
            
            user_id_list = User.pluck(:id)
            
            selected_user_id_index = rand(0..(user_id_list.length - 1 ))
            selected_user_id = user_id_list[ selected_user_id_index ]
            
            
            selected_payment_day_index = rand(0..(payment_day_list.length - 1 ))
            selected_payment_day = payment_day_list[ selected_payment_day_index ]
            
            selected_payment_hour_index = rand(0..(payment_hour_list.length - 1 ))
            selected_payment_hour = payment_hour_list[ selected_payment_hour_index ]
            
          
            
            cg = CollectionGroup.create_object(
                :name             => row['name']            ,            
                :description      => row['description']     ,    
                :branch_id        => branch.id              ,        
                :user_id          => selected_user_id   ,    
                :collection_day   => selected_payment_day          ,        
                :collection_hour  => selected_payment_hour      
            )
            
            if cg.errors.size != 0 
                cg.errors.messages.each {|x| puts x } 
            end
            
    
        end
   
    end
  
end