require 'spec_helper'

describe PrintError do
  
  before(:each) do
    # Account.create_base_objects
    # create users 
    role = {
		  :system => {
		    :administrator => true
		  }
		}

		admin_role = Role.create!(
		  :name        => ROLE_NAME[:admin],
		  :title       => 'Administrator',
		  :description => 'Role for administrator',
		  :the_role    => role.to_json
		)

		role = {
		  :passwords => {
		    :update => true 
		  },
		  :members => {
		    :index => true,
		    :search => true 
		  },
		  :group_loan_products => {
		    :index => true ,
		    :search => true 
		  },
		  :group_loans => {
		    :index => true, 
		    :create => true,
		    :update => true,
		    :destroy => true,
		  },
		  :group_loan_memberships => {
		    :search => true ,
		    :index => true, 
		    :create => true,
		    :update => true,
		    :destroy => true,
		    :deactivate => true 
		  },
		  :group_loan_weekly_collections => {
		    :search => true ,
		    :index => true, 
		    :create => true,
		    :update => true,
		    :destroy => true,
		    :collect => true,
		    :uncollect => true 
		  },
		  
		  :group_loan_weekly_uncollectibles => {
		    :search => true ,
		    :index => true, 
		    :create => true,
		    :update => true,
		    :destroy => true,
		    :clear => true,
		    :collect => true,
		  },
		  :group_loan_premature_clearance_payments => {
		    :search => true ,
		    :index => true, 
		    :create => true,
		    :update => true,
		    :destroy => true 
		  },
		  
		  :savings_entries => {
		    :search => true ,
		    :index => true, 
		    :create => true,
		    :update => true,
		    :destroy => true 
		  }
		}
    @admin = User.create_main_user(  :name => "Admin", :email => "admin@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 
 	@admin.set_as_main_user

 	@admin.reload 
  end

  it "should have created one main user" do
  	@admin.should be_valid
  end
   
 


  it "should be allowed to create print_error" do
  	@print_error = PrintError.create_object( 
  			:user_id => @admin.id, 
  			:saving_date => DateTime.now ,
  			:amount => BigDecimal("510000"),
  			:print_status => "The awesome print status #1",
  			:reason => "The reason is you"
  		)

  	@print_error.errors.size.should == 0 
  	@print_error.should be_valid
  end

  context "created the print error" do
  	before(:each) do
  		@print_error = PrintError.create_object( 
  			:user_id => @admin.id, 
  			:saving_date => DateTime.now ,
  			:amount => BigDecimal("510000"),
  			:print_status => "The awesome print status #1",
  			:reason => "The reason is you"
  		)
  	end

  	it "should be allowed to update print error" do
  		@print_error.update_object(

  				:saving_date => DateTime.now ,
	  			:amount => BigDecimal("150000"),
	  			:print_status => "The awesome print status #1",
	  			:reason => "The reason is you"
  			)

  		@print_error.errors.size.should == 0 
  		@print_error.should be_valid 

  		@print_error.amount.should == BigDecimal("150000")
  	end

  	it "should be allowed to delete print error" do
  		@print_error.delete_object

  		@print_error.persisted?.should be_falsy
  	end


  end

end
