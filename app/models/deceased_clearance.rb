class DeceasedClearance < ActiveRecord::Base
  belongs_to :member 
  
  belongs_to :financial_product, :polymorphic => true 
  attr_accessible :financial_product_id                   ,
                  :financial_product_type                ,
                  :principal_return                      ,
                  :member_id                             ,
                  :description                           ,
                  :additional_savings_account       
             
             
=begin
  For GroupLoan financial product 
=end     
                  
  def group_loan_membership
    if financial_product_type == GroupLoan.to_s
      glm =  GroupLoanMembership.where(
        :group_loan_id => self.financial_product_id, 
        :member_id => self.member_id
      ).first
      # puts "Inside deceased_clearance. The glm: #{glm}"
      return glm
    end
    
    return nil 
  end     
  
  def group_loan_id
    return self.financial_product_id
  end
  
  def group_loan
    if financial_product_type == GroupLoan.to_s
      return GroupLoan.find_by_id self.financial_product_id 
    end
    
    return nil 
  end
                                          
end
