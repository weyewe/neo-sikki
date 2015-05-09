require 'spec_helper'

describe Employee do
  
  before(:each) do
    # puts "This is awesome"

    @branch_1 = Branch.create_object(
      :name => "Branch 1",
      :description => "awesome description",
      :address => "awesome address",
    )

    @branch_2 = Branch.create_object(
      :name => "Branch 2",
      :description => "awesome description",
      :address => "awesome address",
    )
  end

  it "should have 2 branches" do
  	Branch.count.should == 2 
  end
  
  it "should be allowed to create Employee" do
    @employee = Employee.create_object(
      :branch_id => @branch_1,
      :name => "Employee name",
      :description => "awesome address",
    )
    

    @employee.should be_valid 
  end
  
  it "should NOT be allowed to create Employee without name " do
    @employee = Employee.create_object(
      :name => "",
      :description => "awesome description",
      :address => "awesome address",
    )
    
    @employee.errors.size.should_not == 0 

    @employee = Employee.create_object(
      :name => nil,
      :description => "awesome description",
      :address => "awesome address",
    )
    @employee.errors.size.should_not == 0 
  end
 
  
  context "created Employee" do
    before(:each) do
      @name = "Name"
      @employee = Employee.create_object(
        :name => @name,
        :description => "awesome description",
        :address => "awesome address",
      )
    end
    
    it "should not be allowed to confirm Employee" do
      @employee.errors.size.should ==  0
      @employee.should be_valid
    end

    it "should not be allowed to create duplicate Employee name" do
      @name = "Name"
      @employee = Employee.create_object(
        :name => @name,
        :description => "awesome description",
        :address => "awesome address",
      )
      @employee.errors.size.should_not == 0 
      @employee.should_not be_valid 
    end
  end
  
  
end
