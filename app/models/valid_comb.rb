class ValidComb < ActiveRecord::Base
  
  def ValidComb.previous_closing_valid_comb_amount( previous_closing, leaf_account )
    return BigDecimal("0") if previous_closing.nil?
    
    previous_valid_comb = self.where(:closing_id => previous_closing.id, :account_id => leaf_account.id).first
    
    return BigDecimal("0") if previous_valid_comb.nil?
    
    return previous_valid_comb.amount 
  end
end
