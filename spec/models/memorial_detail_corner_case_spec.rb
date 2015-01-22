require 'spec_helper'

describe MemorialDetail do
  
  before(:each) do
    @transaction_datetime = DateTime.now 
    @memorial = Memorial.create_object(
      :transaction_datetime => @transaction_datetime ,
      :description => "awesome description"
    )
    
    @leaf_account_debit = Account.find_by_code(ACCOUNT_CODE[:main_cash_leaf][:code]) 
     
    @leaf_account_credit = Account.find_by_code(ACCOUNT_CODE[:voluntary_savings_leaf][:code])   
    
    @group_account_debit = Account.find_by_code(ACCOUNT_CODE[:cash_and_others][:code])  
    
    
    @amount = BigDecimal("150000")
    @memorial_detail = MemorialDetail.create_object(
      :memorial_id => @memorial.id,
      :account_id  => @leaf_account_debit.id  ,
      :entry_case  => NORMAL_BALANCE[:debit] ,
      :amount      => @amount
    )
    
    @memorial_detail_2 = MemorialDetail.create_object(
      :memorial_id => @memorial.id,
      :account_id  => @leaf_account_credit.id  ,
      :entry_case  => NORMAL_BALANCE[:credit] ,
      :amount      => @amount  
    )
    
    @memorial.confirm(:confirmed_at => DateTime.now )
    
  end
   
  
  it "should not be allowed to create memorial detail from confirmed memorial" do
    @memorial_detail = MemorialDetail.create_object(
      :memorial_id => @memorial.id,
      :account_id  => @leaf_account_debit.id  ,
      :entry_case  => NORMAL_BALANCE[:debit] ,
      :amount      => @amount
    )
    
    @memorial_detail.errors.size.should_not == 0 
  end
  
  
  
  
end
