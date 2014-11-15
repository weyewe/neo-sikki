class CashMutation < ActiveRecord::Base
  
  def CashMutation.create_mutation( source, amount_mutated, confirmation_date, target_cash_bank_id )
    new_object = self.new 
    
    new_object.cash_bank_id = target_cash_bank_id
    new_object.source_document_type = source.class.to_s
    new_object.source_document_id = source.id 
    new_object.source_document_code = source.code
    new_object.amount = amount_mutated
    new_object.save 
  end
end
