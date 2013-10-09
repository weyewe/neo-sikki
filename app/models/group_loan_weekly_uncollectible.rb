class GroupLoanWeeklyUncollectible < ActiveRecord::Base
  attr_accessible :amount, :group_loan_membership_id, :group_loan_id, :group_loan_weekly_collection_id 
  
  belongs_to :group_loan_membership 
  belongs_to :group_loan
  belongs_to :group_loan_weekly_collection 
  
  
  validates_presence_of :group_loan_membership_id, :group_loan_id, :group_loan_weekly_collection_id 
  
  validate :uniq_weekly_collection_and_membership
  validate :use_first_uncollected_weekly_collection
  validate :no_creation_if_weekly_collection_is_confirmed
  
  # after_create :update_group_loan_default_amount_receivable
  
  # def update_group_loan_default_amount_receivable
  #   group_loan.update_default_payment_amount_receivable
  #   
  # end
  
  def all_fields_present?
    group_loan_weekly_collection_id.present? and 
                group_loan_id.present? and 
                group_loan_membership_id.present?
  end
  
  def has_duplicate_entry?
    current_object=  self  
    self.duplicate_entries.count != 0  
  end
  
  def duplicate_entries
    current_object=  self  
    self.class.where(
      :group_loan_membership_id => current_object.group_loan_membership_id ,
      :group_loan_weekly_collection_id => current_object.group_loan_weekly_collection_id,
      :group_loan_id => current_object.group_loan_id
    )
 
  end
  
  def uniq_weekly_collection_and_membership
    msg = 'Sudah ada record yang sama'
    
    current_object = self 
    return if not all_fields_present? 
    


    if not current_object.persisted? and current_object.has_duplicate_entry?  
      errors.add(:group_loan_membership_id ,  msg )  
    elsif current_object.persisted? and 
          ( current_object.group_loan_membership_id_changed? or 
            current_object.group_loan_weekly_collection_id_changed?)   and
          current_object.has_duplicate_entry?   
          # if duplicate entry is itself.. no error
          # else.. some error

        if current_object.duplicate_entries.count == 1  and 
            current_object.duplicate_entries.first.id == current_object.id 
        else
          errors.add(:group_loan_membership_id , msg )  
        end 
    end       
  end
  
  def use_first_uncollected_weekly_collection
    return if not all_fields_present? 
    return if self.persisted? 
    
    if group_loan.first_uncollected_weekly_collection.id != self.group_loan_weekly_collection_id 
      msg = "Pengumpulan minggu #{group_loan_weekly_collection.week_number} telah ditutup"
      self.errors.add(:group_loan_weekly_collection_id , msg  )
      return self 
    end
  end
  
  def no_creation_if_weekly_collection_is_confirmed
    return if not all_fields_present? 
    return if self.persisted? 
    
    if group_loan_weekly_collection.is_collected?
      self.errors.add(:group_loan_weekly_collection_id, "Sudah terkonfirmasi. Tidak bisa ditambah.")
    end
  end
  
  
  
  
  
  def update_amount 
    self.amount = self.group_loan_membership.group_loan_product.weekly_payment_amount
    self.principal = self.group_loan_membership.group_loan_product.principal
    self.save
    
    
  end
  
  
  def self.create_object(params)
    new_object = self.new 
    
    new_object.group_loan_id                     = params[:group_loan_id]  
    new_object.group_loan_membership_id          = params[:group_loan_membership_id]  
    new_object.group_loan_weekly_collection_id   = params[:group_loan_weekly_collection_id]
    
    if new_object.save 
      new_object.update_amount
    end
    
    return new_object
  end
  
  def update_object(params)
    if self.group_loan_weekly_collection.is_confirmed? or 
        self.group_loan_weekly_collection.is_collected? 
      self.errors.add(:generic_errors, "Pengumpulan mingguan terkumpul atau terkonfirmasi ")
      return self 
    end
    
    
    self.group_loan_id                     = params[:group_loan_id]
    self.group_loan_membership_id          = params[:group_loan_membership_id]  
    self.group_loan_weekly_collection_id   = params[:group_loan_weekly_collection_id]
    
    
    if self.save 
      self.update_amount
    end
    
    
    self.save  
    
  end
  
  def delete_object
    if self.group_loan_weekly_collection.is_confirmed? or 
        self.group_loan_weekly_collection.is_collected? 
      self.errors.add(:generic_errors, "Pengumpulan mingguan terkumpul atau terkonfirmasi ")
      return self 
    end
    
    
    
    self.destroy 
    
    # journal posting or group_loan update will only be done @weekly_collection confirmation
  end
  
  def clear(params)
    if not self.is_collected? 
      self.errors.add(:generic_errors, "Belum dikumpulkan oleh field officer")
      return self 
    end
    
    
    if not self.group_loan_weekly_collection.is_confirmed?
      self.errors.add(:generic_errors, "Belum konfirmasi pengumpulan mingguan")
      return self 
    end
    
    if self.is_cleared? 
      self.errors.add(:generic_errors, "Sudah di selesaikan")
      return self 
    end
    
    self.is_cleared = true 
    self.cleared_at = params[:cleared_at]
    
    if self.cleared_at.nil?
      self.errors.add(:cleared_at, "Harus ada tanggal penutupan")
      return self 
    end
    
  
    if self.save 
      self.group_loan.update_bad_debt_allowance(  -1 * self.principal)
      # update the journal posting 
    end
  end
  
end
