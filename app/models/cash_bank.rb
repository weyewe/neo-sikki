class CashBank < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :office 
  has_many :cash_mutations 
  has_many :cash_bank_adjustments
  
  validates_presence_of  :name, 
                        :description,
                        :status 
                        
  validates_uniqueness_of :name 
        
    
  
  
  validate :status_must_be_valid  
  validate :only_one_cashier_cashbank
  
  def status_must_be_valid
    return  if not all_fields_present?
    
    if not [  
              CASH_BANK_STATUS[:bank],
              CASH_BANK_STATUS[:cashier],
              CASH_BANK_STATUS[:other_cash] ].include?( status ) 
      self.errors.add(:generic_errors , "Status cashbank must be present")
      return self
    end
    
    
  end
  
  def only_one_cashier_cashbank
    if not self.persisted? 
      if CashBank.where(:status => CASH_BANK_STATUS[:cashier]).count != 0 
        self.errors.add(:status , "Hanya boleh satu kasir di satu kantor")
        return self 
      end
    end
  end
   
   
  
  def all_fields_present?
    name.present? and 
    status.present?         
  end
  
  
  
  def self.create_object(   params) 
    new_object                 = self.new 
    new_object.name            = params[:name]
    new_object.description     = params[:description]
    new_object.status          = params[:status]
    
    new_object.save 
    return new_object
  end
  
  def update_object( params ) 
    if self.status == CASH_BANK_STATUS[:cashier] and
      not params[:status].nil? and 
      self.status != params[:status].to_i
      
      self.errors.add(:status, "Tidak boleh mengubah status kasir")
      return self 
    end
    
    self.name            = params[:name]
    self.description     = params[:description]
    self.status     = params[:status]
    
    self.save 
    return self
  end
  
  def delete_object
    if self.cash_mutations.count != 0 
      self.errors.add(:generic_errors, "sudah ada cash mutation")
      return self 
    end
    
    if self.status == CASH_BANK_STATUS[:cashier]
      self.errors.add(:generic_errors, "Tidak boleh delete cashier")
      return self 
    end
    
    self.destroy 
  end
  
  def update_amount( amount ) 
    self.amount += amount 
    self.save 
  end
   
  
end

