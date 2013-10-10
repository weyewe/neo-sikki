class DeceasedClearance < ActiveRecord::Base
  attr_accessible :financial_product_id,
                  :financial_product_type                ,
                  :principal_return                      ,
                  :member_id                             ,
                  :description                           ,
                  :additional_savings_account            
                                          
end
