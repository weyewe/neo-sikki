class Office < ActiveRecord::Base
  
  has_many :group_loans 
  
  def self.create_object(params)
    new_object           = self.new
    new_object.name      = params[:name]
    new_object.code   = params[:code]
    new_object.save
    
    return new_object 
  end
  
  def update_object(params)
    self.name      = params[:name]
    self.code   = params[:code]
    self.save
    
    return self 
  end
  
  
end
