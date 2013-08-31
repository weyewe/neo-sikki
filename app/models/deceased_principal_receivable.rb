class DeceasedPrincipalReceivable < ActiveRecord::Base
  attr_accessible :member_id,:amount_receivable
  
  def create_payment
    # pretty much to be done with accounting. 
  end
end
