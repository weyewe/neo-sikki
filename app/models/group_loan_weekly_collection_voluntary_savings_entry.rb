class GroupLoanWeeklyCollectionVoluntarySavingsEntry < ActiveRecord::Base
  belongs_to :group_loan_membership
  belongs_to :group_loan_weekly_collection
  
  validates_presence_of :amount, :group_loan_membership_id, :group_loan_weekly_collection_id
  
  validate :valid_amount
  validate :valid_group_loan_membership_id
  validate :valid_group_loan_weekly_collection_id
  validate :valid_glm_group_loan_weekly_collection_id 
  validate :group_loan_weekly_collection_not_collected
  validate :group_loan_membership_is_still_active
  
  def valid_amount
    return if not self.amount.present? 
    
    if self.amount <= BigDecimal('0')
      self.errors.add(:amount, "Harus lebih besar daripada 0")
      return self 
    end
  end
  
  def valid_group_loan_membership_id 
    return if self.group_loan_membership_id.nil? 
    begin
      glm = GroupLoanMembership.find self.group_loan_membership_id
    rescue
      self.errors.add(:group_loan_membership_id, "Harus Valid")
    end
  end
  
  def valid_group_loan_weekly_collection_id
    return if self.group_loan_weekly_collection_id.nil? 
    
    begin
      glm = GroupLoanWeeklyCollection.find self.group_loan_weekly_collection_id
    rescue
      self.errors.add(:group_loan_weekly_collection_id, "Harus Valid")
    end
  end
  
  def valid_glm_group_loan_weekly_collection_id
    return if group_loan_membership_id.nil? or 
            group_loan_weekly_collection_id.nil?
            
    if group_loan_membership.group_loan_id != group_loan_weekly_collection.group_loan_id
      self.errors.add(:generic_errors, "Invalid GroupLoanMembership and GroupLoanWeeklyCollection combination")
    end
  end
  
  def group_loan_weekly_collection_not_collected
    return if group_loan_weekly_collection_id.nil?
    
    if group_loan_weekly_collection.is_collected?
      self.errors.add(:generic_errors, "Sudah terkumpul")
    end
  end
  
  def group_loan_membership_is_still_active
    return if group_loan_membership_id.nil?
    return if group_loan_weekly_collection_id.nil? 
    
    active_glm_id_list = group_loan_weekly_collection.active_group_loan_memberships.map {|x| x.id}
    if active_glm_id_list.include?(self.group_loan_membership_id)
      self.errors.add(:generic_errors, "Member sudah tidak aktif di group ini")
    end
  end
  
  def self.create_object(  params)
   
    new_object = self.new
    
    new_object.amount        = BigDecimal( params[:amount] )
    new_object.group_loan_membership_id = params[:group_loan_membership_id]
    new_object.group_loan_weekly_collection_id = params[:group_loan_weekly_collection_id]
    
    new_object.save
    
    return new_object 
  end
  
  def  update_object( params ) 
    
    if self.group_loan_weekly_collection.is_collected?
      self.errors.add(:generic_errors, "Sudah terkumpul")
      return self
    end
    
    self.amount        = BigDecimal( params[:amount] )
    self.group_loan_membership_id = params[:group_loan_membership_id]
    self.group_loan_weekly_collection_id = params[:group_loan_weekly_collection_id]
    
    self.save 
    
    return self
  end
  
  def delete_object
    if self.group_loan_weekly_collection.is_collected?
      self.errors.add(:generic_errors, "Sudah terkumpul")
      return self
    end
    
    self.destroy 
  end
  
  def confirm
    # create the savings_entries
  end
  
  
  
end
