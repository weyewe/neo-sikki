class GroupLoanWeeklyCollectionVoluntarySavingsEntry < ActiveRecord::Base
  belongs_to :group_loan_membership
  belongs_to :group_loan_weekly_collection
  
  def self.create_object(  params)
   
    new_object = self.new
    
    new_object.amount        = BigDecimal( params[:amount] )
    new_object.group_loan_membership_id = params[:group_loan_membership_id]
    new_object.group_loan_weekly_collection_id = params[:group_loan_weekly_collection_id]
    
    new_object.save
    
    return new_object 
  end
  
  def  update_object( params ) 
    
    self.amount        = BigDecimal( params[:amount] )
    self.group_loan_membership_id = params[:group_loan_membership_id]
    self.group_loan_weekly_collection_id = params[:group_loan_weekly_collection_id]
    
    self.save 
    
    return self
  end
  
  def delete_object
    if self.is_started? or self.group_loan_memberships.count != 0
      self.errors.add(:generic_errors, "Sudah ada keanggotaan pinjaman group")
      return self 
    end
    
    self.destroy 
  end
  
  
  
end
