class CollectionGroup < ActiveRecord::Base
    belongs_to :user 
    belongs_to :branch  
        
      
      
    def self.create_object(params) 
        new_object = self.new 
        new_object.name             = params[:name           ]                
        new_object.description      = params[:description    ]        
        new_object.branch_id        = params[:branch_id      ]            
        new_object.user_id          = params[:user_id        ]        
        new_object.collection_day   = params[:collection_day ]            
        new_object.collection_hour  = params[:collection_hour]      
        
        new_object.save 
        
        return new_object 
    end 
    
    def update_object( params ) 

        self.name             = params[:name           ]                
        self.description      = params[:description    ]        
        self.branch_id        = params[:branch_id      ]            
        self.user_id          = params[:user_id        ]        
        self.collection_day   = params[:collection_day ]            
        self.collection_hour  = params[:collection_hour]     
        self.save 
        
        return self 
    end 
    
    
    def collection_day_name 
        if collection_day == PAYMENT_DAY[:monday]
            return "Senin"
        elsif   collection_day == PAYMENT_DAY[:tuesday]
            return "Selasa"
        elsif   collection_day == PAYMENT_DAY[:wednesday]
            return "Rabu"
        elsif   collection_day == PAYMENT_DAY[:thursday]
            return "Kamis"
        elsif   collection_day == PAYMENT_DAY[:friday]  
            return "Jumat"
        end
    end
    
    
    def collection_hour_name 

        if collection_hour == PAYMENT_HOUR[:hour_8_00]
            return "08.00"
        elsif   collection_hour == PAYMENT_HOUR[:hour_8_30]
            return "08.30"
        elsif   collection_hour == PAYMENT_HOUR[:hour_9_00]
            return "09.00"
        elsif   collection_hour == PAYMENT_HOUR[:hour_9_30]
            return "09.30"
        elsif   collection_hour == PAYMENT_HOUR[:hour_10_00]  
            return "10.00"
        elsif   collection_hour == PAYMENT_HOUR[:hour_10_30]  
            return "10.30"
        elsif   collection_hour == PAYMENT_HOUR[:hour_11_00]  
            return "11.00"
        elsif   collection_hour == PAYMENT_HOUR[:hour_11_30]  
            return "11.30"
        elsif   collection_hour == PAYMENT_HOUR[:hour_12_00]  
            return "12.00"
        elsif   collection_hour == PAYMENT_HOUR[:hour_12_30]  
            return "12.30"
        elsif   collection_hour == PAYMENT_HOUR[:hour_13_00]  
            return "13.00"
        elsif   collection_hour == PAYMENT_HOUR[:hour_13_30]  
            return "13.30"
        elsif   collection_hour == PAYMENT_HOUR[:hour_14_00]  
            return "14.00"
        elsif   collection_hour == PAYMENT_HOUR[:hour_14_30]  
            return "14.30"
        elsif   collection_hour == PAYMENT_HOUR[:hour_15_00]  
            return "15.00"
        elsif   collection_hour == PAYMENT_HOUR[:hour_15_30]  
            return "15.30"
        elsif   collection_hour == PAYMENT_HOUR[:hour_16_00]  
            return "16.00"
        elsif   collection_hour == PAYMENT_HOUR[:hour_16_30]  
            return "16.30"
        elsif   collection_hour == PAYMENT_HOUR[:hour_17_00]  
            return "17.00"
        end 


    end
end
