

class CashBankAdjustment < ActiveRecord::Base
  attr_accessible :cash_bank_id, :adjustment_date, :amount 
  
  validates_presence_of :cash_bank_id, :adjustment_date, :amount 
                
  has_many :cash_mutations 
  belongs_to :cash_bank
  
  validate :resulting_amount_must_not_be_negative
  validate :amount_must_not_be_zero
  validate :valid_cash_bank_id 
  
  
  def all_fields_present?
    cash_bank_id.present? and
    amount.present? and 
    adjustment_date.present? 
  end
  
  def amount_must_not_be_zero
    return if not all_fields_present? 
    
    if self.amount == BigDecimal("0")
      self.errors.add(:amount, "Tidak boleh 0")
      return self 
    end
  end
  
  def valid_cash_bank_id
    return if not all_fields_present?
    
    if CashBank.find_by_id( self.cash_bank_id).nil?
      self.errors.add(:generic_errors, "CashBank harus valid")
      return self 
    end
  end
  
  
  def resulting_amount_must_not_be_negative
    return if not all_fields_present?
    return if self.is_persisted? 
        
    if cash_bank.amount + self.amount < 0
      self.errors.add(:amount, "Jumlah akhir tidak valid (lebih kecil dari 0)")
      return self 
    end
  end
  
  
  

  
=begin
  # Independent savings, 
=end
  def self.create_object( params ) 
    new_object = self.new 
    
    new_object.cash_bank_id      = params[:cash_bank_id]  
    new_object.adjustment_date    =  params[:adjustment_date] 
    new_object.amount                 = BigDecimal(params[:amount] || '0')
    
    if new_object.save 
      new_object.code = "CAD" + self.count.to_s
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
    
    self.cash_bank_id      = params[:cash_bank_id]  
    self.adjustment_date    =  params[:adjustment_date] 
    self.amount                 = BigDecimal(params[:amount] || '0')
    self.save
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
    
    
    if cash_bank.amount + self.amount < 0
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
      CashMutation.create_mutation( self, self.amount, self.confirmed_at, self.cash_bank_id )
      cash_bank.update_amount( self.amount )  
       
    end
  end
  
   
  def unconfirm
    if not self.is_confirmed?
      self.errors.add(:generic_errors, 'Belum dikonfirmasi.')
      return self
    end
    
    if cash_bank.amount - self.amount < BigDecimal("0")
      self.errors.add(:generic_errors, "Jumlah akhir di cashbank menjadi negative")
      return self 
    end
    
    self.is_confirmed = false
    self.confirmed_at = nil 
    
    if self.save 
      CashMutation.create_mutation( self, -1*self.amount, DateTime.now  )
      cash_bank.update_amount( -1*self.amount )
    end
  end
  
                      
end
