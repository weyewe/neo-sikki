class MemorialDetail < ActiveRecord::Base
  belongs_to :memorial 
   
  validates_presence_of :entry_case
  validates_presence_of :memorial_id 
  validates_presence_of :amount
  validates_presence_of :account_id
  
  
  validate :valid_entry_case
  validate :amount_not_zero
  validate :valid_memorial_id
  validate :account_id_must_be_leaf_account 
  
  def account_id_must_be_leaf_account
    return if not account_id.present?
    account_object = Account.find_by_id account_id 
    
    if account_object.nil?
      self.errors.add(:account_id, "Harus valid")
      return self 
    end
    
    if account_object.account_case != ACCOUNT_CASE[:ledger] 
      self.errors.add(:account_id , "Harus ledger account")
      return self 
    end
    
  end
  
  def valid_entry_case
    if not [
      NORMAL_BALANCE[:credit],
        NORMAL_BALANCE[:debit]
      ].include?( self.entry_case)
      
      self.errors.add(:entry_case, "Harus dipilih")
      return self 
      
    end
  end
  
  def amount_not_zero
    return if not self.amount.present?
    
    if amount <= BigDecimal("0")
      self.errors.add(:amount, "Tidak boleh negative")
      return self 
    end
  end
  
  def valid_memorial_id
    return if not memorial_id.present?
    memorial_object = Memorial.find_by_id memorial_id
    
    if not memorial_object 
      self.errors.add(:memorial_id, "Harus valid")
      return self 
    end
    
    if memorial_object.is_confirmed?
      self.errors.add(:memorial_id, "Sudah di konfirmasi")
      return self 
    end
    
    if memorial_object.is_deleted?
      self.errors.add(:memorial_id, "Sudah di hapus")
      return self 
    end
    
    
    
  end
  
  def self.create_object(params)
    new_object           = self.new
    
    new_object.memorial_id = params[:memorial_id]
    new_object.account_id = params[:account_id]
    new_object.entry_case = params[:entry_case]
    new_object.amount = params[:amount]
    
    
     
    

    if new_object.save
      new_object.transaction_datetime = new_object.memorial.transaction_datetime
      new_object.description = new_object.memorial.description
      new_object.save 
    end
    
    return new_object 
  end
  
  def update_object( params ) 
    
    
    
    self.account_id = params[:account_id]
    self.entry_case = params[:entry_case]
    self.amount = params[:amount]
    self.save
    
    return self 
  end
   
  
  def delete_object
    if self.memorial.is_confirmed?
      self.errors.add(:generic_errors, "Sudah konfirmasi memorial")
    end
    if self.memorial.is_deleted?
      self.errors.add(:generic_errors, "Sudah hapus memorial")
    end
    
    self.destroy 
    
    return self 
  end
  
end
