
class CashBankMutation < ActiveRecord::Base
  attr_accessible :target_cash_bank_id, :source_cash_bank_id, , :mutation_date, :description, :amount 
  
  validates_presence_of :target_cash_bank_id, :source_cash_bank_id, :mutation_date, :amount 
                
  has_many :cash_mutations 
  
  validate :resulting_amount_must_not_be_negative
  validate :amount_must_be_positive
  validate :valid_target_and_source_cash_bank_id
  
  
  def all_fields_present?
    target_cash_bank_id.present? and
    source_cash_bank_id.present? and
    amount.present? and 
    mutation_date.present? 
  end
  
  def amount_must_be_positive
    return if not all_fields_present? 
    
    if self.amount <= BigDecimal("0")
      self.errors.add(:amount, "Harus positive")
      return self 
    end
  end
  
  def target_cash_bank
    CashBank.find_by_id self.target_cash_bank_id 
  end
  
  def source_cash_bank
    CashBank.find_by_id self.source_cash_bank_id 
  end
  
  
  
  def valid_target_and_source_cash_bank_id
    return if not all_fields_present?
    
    if target_cash_bank_id == source_cash_bank_id
      self.errors.add(:generic_errors, "Target dan Source CashBank harus berbeda")
    end
    
    if target_cash_bank.nil?
      self.errors.add(:target_cash_bank_id, "Harus valid")
    end
    
    if source_cash_bank.nil?
      self.errors.add(:source_cash_bank_id, "Harus valid")
    end
    
  end
  
  
  
  
  def resulting_amount_must_not_be_negative
    return if not all_fields_present?
    return if self.is_persisted? 
        
    if source_cash_bank.amount - self.amount < 0
      self.errors.add(:amount, "Jumlah akhir dari source cash bank tidak valid (lebih kecil dari 0)")
      return self 
    end
  end
  
  
  

  
=begin
  # Independent savings, 
=end
  def self.create_object( params ) 
    new_object = self.new 
    
    new_object.source_cash_bank_id      = params[:source_cash_bank_id]  
    new_object.target_cash_bank_id      = params[:target_cash_bank_id]  
    new_object.mutation_date    =  params[:mutation_date] 
    new_object.amount                 = BigDecimal(params[:amount] || '0')
    
    if new_object.save 
      new_object.code = "CBM" + self.count.to_s
      new_object.save 
    end
     
    return new_object
  end
  
  def  update_object( params ) 
    
    if self.is_confirmed?
      self.errors.add(:generic_errors, 'Sudah dikonfirmasi. Silakan unconfirm')
      return self 
    end
    
    if self.is_deleted?
      self.errors.add(:generic_errors, "sudah dihapus")
      return self 
    end
    
    self.source_cash_bank_id      = params[:source_cash_bank_id]  
    self.target_cash_bank_id      = params[:target_cash_bank_id]  
    self.mutation_date    =  params[:mutation_date] 
    self.amount                 = BigDecimal(params[:amount] || '0')
    
    
    
    return self.save
  end
  
  
=begin
  The rest 
=end
  
  def delete_object
    if self.is_confirmed?
      self.errors.add(:generic_errors, 'Sudah dikonfirmasi. Silakan unconfirm')
      return self
    end
    
    self.is_deleted = true 
    self.save 
  end
  
  
  def confirm(params)
    if self.is_confirmed?
      self.errors.add(:generic_errors, 'Sudah dikonfirmasi.')
      return self
    end
    
    if self.is_deleted?
      self.errors.add(:generic_errors, "Sudah di hapus")
      return self 
    end
    
    # validate that the final amount will never be negative 
    
    if params[:confirmed_at].nil? or not params[:confirmed_at].is_a?(DateTime)
      self.errors.add(:confirmed_at, "Harus ada tanggal konfirmasi pembayaran")
      return self 
    end
    
    
    if source_cash_bank.amount - self.amount < 0
      self.errors.add(:amount, "Jumlah akhir tidak valid (lebih kecil dari 0)")
      return self 
    end
    
    
    if self.errors.size != 0 
      self.errors.add(:generic_errors, "Error")
      return self 
    end
    
    
    self.is_confirmed = true
    self.confirmed_at = params[:confirmed_at]
    if self.save
      # create cash mutation 
      CashMutation.create_mutation( self, -1*self.amount, self.confirmed_at, self.source_cash_bank_id )
      source_cash_bank.update_amount( -1*self.amount )  
       
      CashMutation.create_mutation( self, self.amount, self.confirmed_at, self.target_cash_bank_id )
      target_cash_bank.update_amount( self.amount )
    end
  end
  
   
  def unconfirm
    if not self.is_confirmed?
      self.errors.add(:generic_errors, 'Belum dikonfirmasi.')
      return self
    end
    
    if target_cash_bank.amount - self.amount < BigDecimal("0")
      self.errors.add(:generic_errors, "Jumlah akhir di target cashbank menjadi negative")
      return self 
    end
    
    self.is_confirmed = false
    self.confirmed_at = nil 
    
    now = DateTime.now
    if self.save 
      CashMutation.create_mutation( self, self.amount, now, self.source_cash_bank_id )
      source_cash_bank.update_amount( self.amount )  
       
      CashMutation.create_mutation( self, -1*self.amount,now, self.target_cash_bank_id )
      target_cash_bank.update_amount( -1*self.amount )
    end
  end
  
                      
end
