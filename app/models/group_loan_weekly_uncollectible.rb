class GroupLoanWeeklyUncollectible < ActiveRecord::Base
  attr_accessible :amount, :group_loan_membership_id, :group_loan_id, :group_loan_weekly_collection_id 
  
  belongs_to :group_loan_membership 
  belongs_to :group_loan
  belongs_to :group_loan_weekly_collection 
  
  
  validates_presence_of :group_loan_membership_id, :group_loan_id, :group_loan_weekly_collection_id , :clearance_case
  
  validate :uniq_weekly_collection_and_membership
  validate :use_first_uncollected_weekly_collection
  validate :no_creation_if_weekly_collection_is_confirmed
  validate :valid_clearance_case
  validate :valid_active_member 
  
 
  
  def valid_active_member
    return if not all_fields_present?
    return if not self.group_loan.is_closed?
      
    
    member = self.group_loan_membership.member
    if  not self.group_loan.is_closed? and not  self.group_loan_membership.is_active? 
      self.errors.add(:generic_errors, "Member #{member.name} tidak aktif")
      return self 
    end
  end
  
  def valid_clearance_case
    return if not all_fields_present?
    
    if not [
      UNCOLLECTIBLE_CLEARANCE_CASE[:end_of_cycle],
      UNCOLLECTIBLE_CLEARANCE_CASE[:in_cycle]
      ].include?(self.clearance_case)
      self.errors.add(:clearance_case, "Kasus penyelesaian pembayaran tak tertagih harus dipilih")
      return self 
    end
  end
  
  def all_fields_present?
    group_loan_weekly_collection_id.present? and 
                group_loan_id.present? and 
                group_loan_membership_id.present? and 
                clearance_case.present? 
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
      
      msg = "Pengumpulan minggu #{group_loan_weekly_collection.week_number} tidak valid"
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
  
  def create_allowance_transaction_data_from_uncollectible
    # 1. get the principal, 
    # 2. use that amount. credit piutang, debit allowance
    member = self.group_loan_membership.member
    group_loan = self.group_loan
    group_loan_weekly_collection = self.group_loan_weekly_collection
    message = "Uncollectible Payment. GroupLoan: #{group_loan.name}, #{group_loan.group_number} " + 
              "Member: #{member.name}, #{member.id_number} " + 
              "Week: #{group_loan_weekly_collection.week_number}"
              
    ta = TransactionData.create_object({
      :transaction_datetime => self.group_loan_weekly_collection.collected_at,
      :description =>  message,
      :transaction_source_id => self.id , 
      :transaction_source_type => self.class.to_s ,
      :code => TRANSACTION_DATA_CODE[:group_loan_uncollectible_allowance],
      :is_contra_transaction => false 
    }, true )
    
     
    
    TransactionDataDetail.create_object(
      :transaction_data_id => ta.id,        
      :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_bda_leaf][:code]).id      ,
      :entry_case          => NORMAL_BALANCE[:debit]     ,
      :amount              => self.principal,
      :description => message
    )
    
    TransactionDataDetail.create_object(
      :transaction_data_id => ta.id,        
      :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_ar_leaf][:code]).id        ,
      :entry_case          => NORMAL_BALANCE[:credit]     ,
      :amount              => self.principal,
      :description => message
    )
    
    ta.confirm 
  end
  
  def create_contra_allowance_transaction_data
    ta = TransactionData.where({
      :transaction_source_id => self.id , 
      :transaction_source_type => self.class.to_s ,
      :code => TRANSACTION_DATA_CODE[:group_loan_uncollectible_allowance],
      :is_contra_transaction => false 
    } ).order("id DESC").first 
    
    ta.create_contra_and_confirm if not ta.nil?
  end
  
  def create_allowance_in_cycle_clearance_transaction_data
    # 1. Cash ++ 1 week worth of payment
    # 2. allowance is being deducted 
    
    member = self.group_loan_membership.member
    group_loan = self.group_loan
    group_loan_weekly_collection = self.group_loan_weekly_collection
    message = "Uncollectible Payment In-Cycle Clearance. GroupLoan: #{group_loan.name}, #{group_loan.group_number} " + 
              "Member: #{member.name}, #{member.id_number} " + 
              "Week: #{group_loan_weekly_collection.week_number}"
              
    glp = group_loan_membership.group_loan_product   
    
    ta = TransactionData.create_object({
      :transaction_datetime => self.collected_at,
      :description =>  message,
      :transaction_source_id => self.id , 
      :transaction_source_type => self.class.to_s ,
      :code => TRANSACTION_DATA_CODE[:group_loan_in_cycle_uncollectible_clearance],
      :is_contra_transaction => false 
    }, true )
           
    
    TransactionDataDetail.create_object(
      :transaction_data_id => ta.id,        
      :account_id          => Account.find_by_code(ACCOUNT_CODE[:main_cash_leaf][:code]).id      ,
      :entry_case          => NORMAL_BALANCE[:debit]     ,
      :amount              => glp.weekly_payment_amount,
      :description => message
    )

    TransactionDataDetail.create_object(
      :transaction_data_id => ta.id,        
      :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_interest_revenue_leaf][:code]).id        ,
      :entry_case          => NORMAL_BALANCE[:credit]     ,
      :amount              => glp.interest,
      :description => message
    )
    TransactionDataDetail.create_object(
      :transaction_data_id => ta.id,        
      :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_bda_leaf][:code]).id        ,
      :entry_case          => NORMAL_BALANCE[:credit]     ,
      :amount              => glp.principal,
      :description => message
    )
    TransactionDataDetail.create_object(
      :transaction_data_id => ta.id,        
      :account_id          => Account.find_by_code(ACCOUNT_CODE[:compulsory_savings_leaf][:code]).id        ,
      :entry_case          => NORMAL_BALANCE[:credit]     ,
      :amount              => glp.compulsory_savings,
      :description => message
    )
    
    ta.confirm 
  end
  
  def create_contra_allowance_in_cycle_clearance_transaction_data
    ta = TransactionData.create_object({
      :transaction_source_id => self.id , 
      :transaction_source_type => self.class.to_s ,
      :code => TRANSACTION_DATA_CODE[:group_loan_in_cycle_uncollectible_clearance],
      :is_contra_transaction => false 
    }, true )
    
    ta.create_contra_and_confirm if not ta.nil?
  end
  
  
  
  
  
  def self.create_object(params)
    new_object = self.new 
    
    new_object.group_loan_id                     = params[:group_loan_id]  
    new_object.group_loan_membership_id          = params[:group_loan_membership_id]  
    new_object.group_loan_weekly_collection_id   = params[:group_loan_weekly_collection_id]
    new_object.clearance_case = params[:clearance_case]
    # even if it is cleared in the cycle, or at the end of cycle, there still be allowance
    
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
    
    self.clearance_case = params[:clearance_case]
    
    if group_loan.first_uncollected_weekly_collection.id != self.group_loan_weekly_collection_id 
      
      msg = "Pengumpulan minggu #{group_loan_weekly_collection.week_number} tidak valid"
      self.errors.add(:group_loan_weekly_collection_id , msg  )
      return self 
    end
    
    
    self.update_amount if self.save  
  end
  
  def delete_object
    if self.is_collected?
      self.errors.add(:generic_errors, 'Sudah terkumpul. Tidak bisa di hapus')
      return self 
    end
    
    if self.group_loan_weekly_collection.is_confirmed? or 
        self.group_loan_weekly_collection.is_collected? 
      self.errors.add(:generic_errors, "Pengumpulan mingguan terkumpul atau terkonfirmasi ")
      return self 
    end
    
    self.destroy 
  end
  
  def collect( params ) 
    if self.clearance_case == UNCOLLECTIBLE_CLEARANCE_CASE[:end_of_cycle]
      msg =  "Penyelesaian tak tertagih dilakukan dengan cara pemotongan tabungan wajib"
      self.errors.add(:generic_errors, msg )
      return self 
    end
    
    if self.is_collected?
      self.errors.add(:generic_errors, "Sudah dikumpul")
      return self 
    end
    
    if params[:collected_at].nil? or not params[:collected_at].is_a?(DateTime)
      self.errors.add(:collected_at, "Harus ada tanggal pengumpulan")
      return self
    end
    
    if not self.group_loan_weekly_collection.is_confirmed? 
      self.errors.add(:generic_errors, "Weekly collection belum di konfirmasi")
      return self
    end
    
    self.is_collected = true 
    self.collected_at = params[:collected_at]
    self.save 
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
      self.errors.add(:generic_errors, "Sudah di lunaskan")
      return self 
    end
    
    if params[:cleared_at].nil? or not params[:cleared_at].is_a?(DateTime)
      self.errors.add(:cleared_at, "Harus ada tanggal penutupan")
      return self 
    end
    
    self.is_cleared = true 
    self.cleared_at = params[:cleared_at]
  
    if self.save 
      self.group_loan.update_bad_debt_allowance(  -1 * self.principal)
      # update the journal posting 
      
      # in cycle is by default. if it is not in-cycle, call the #clear_end_of_cycle method 
      if self.clearance_case == UNCOLLECTIBLE_CLEARANCE_CASE[:in_cycle]
        self.create_allowance_in_cycle_clearance_transaction_data
      end
    end
  end
  
  def uncollect
    if self.is_collected == false
      self.errors.add(:generic_errors, "Belum ada collection")
      return self 
    end
    
    
    self.is_collected = false 
    self.collected_at = nil
    self.save
  end
  
  def unclear
    if self.is_cleared == false
      self.errors.add(:generic_errors, "Belum ada clearance")
      return self 
    end
    
    self.is_cleared = false 
    self.cleared_at = nil
    
    
    if self.save
      self.group_loan.update_bad_debt_allowance(   self.principal )
      self.create_contra_allowance_in_cycle_clearance_transaction_data
    end
    
  end
  
  def clear_end_of_cycle
    self.is_cleared = true 
    self.cleared_at = self.group_loan.closed_at 
    if self.save
    else
      self.errors.messages.each {|x| puts "error message in uncollectible clearance: #{x}"}
    end
  end
  
end
