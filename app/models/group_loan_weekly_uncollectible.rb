class GroupLoanWeeklyUncollectible < ActiveRecord::Base
  attr_accessible :amount, :group_loan_membership_id, :group_loan_id, :group_loan_weekly_collection_id 
  
  belongs_to :group_loan_membership 
  belongs_to :group_loan
  belongs_to :group_loan_weekly_collection 
  
  validate :uniq_weekly_collection_and_membership
  validates_presence_of :group_loan_membership_id, :group_loan_id, :group_loan_weekly_collection_id 
  
  
  def all_fields_present?
    group_loan_weekly_collection_id.present? and 
                group_loan_id.present? and 
                group_loan_membership_id.present?
  end
  
  def uniq_weekly_collection_and_membership
    msg = 'Sudah ada record yang sama'
    
    current_object = self 
    return if not all_fields_present? 
    


    if not current_object.persisted? and current_object.has_duplicate_entry?  
      errors.add(:group_loan_membership_id ,  msg )  
    elsif current_object.persisted? and 
          current_object.name_changed?  and
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
  
   
  
  def has_duplicate_entry?
    current_object=  self  
    self.duplicate_entries.count != 0  
  end
  
  def duplicate_entries
    current_object=  self  
    self.class.find(:all, :conditions => {
      :group_loan_membership_id => current_object.group_loan_membership_id ,
      :group_loan_weekly_collection_id => current_object.group_loan_weekly_collection_id,
      :group_loan_id => current_object.group_loan_id 
    })
  end
  
  
end
