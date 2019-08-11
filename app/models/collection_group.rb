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
end
