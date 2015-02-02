require 'spec_helper'

describe Office do
  before(:each) do
    @office = Office.create_object(:name => "Office 1", :code => "xx")
  end
  
  it "should create office" do
    @office.errors.size.should ==0  
    @office.should be_valid 
  end
  
  context "creating linked data" do
    before(:each) do
      @group_loan = @office.group_loans.create_object({
        :name                             => "Group Loan 1" ,
        :number_of_meetings => 3 
      })
      
    end
    
    it "should create group loan" do
      @group_loan.errors.size.should == 0 
      @group_loan.office_id.should == @office.id 
    end
    
    context "creating second office" do
      before(:each) do
        @second_office = Office.create_object(:name => "Office 2", :code => "xx")
        @group_loan_2 = @office.group_loans.create_object({
          :name                             => "Group Loan 2" ,
          :number_of_meetings => 3 
        })
      end
      
      it "should not return group loan from office 1" do
        group_loan = @second_office.group_loans.find_by_id @group_loan.id 
        
        group_loan.should be_nil 
      end
    end
  end
end
