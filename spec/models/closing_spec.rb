require 'spec_helper'

describe Closing do
  
  before(:each) do
    # Account.create_base_objects
    # create users 
    (1..8).each do |number|
      Member.create_object({
        :name =>  "Member #{number}",
        :address => "Address alamat #{number}" ,
        :id_number => "342432#{number}"
      })
    end
    
    @total_weeks_1        = 8 
    @principal_1          = BigDecimal('20000')
    @interest_1           = BigDecimal("4000")
    @compulsory_savings_1 = BigDecimal("6000")
    @admin_fee_1          = BigDecimal('10000')
    @initial_savings_1          = BigDecimal('0')
    
    @group_loan_product_1 = GroupLoanProduct.create_object({
      :name => "Produk 1, 500 Ribu",
      :total_weeks        =>  @total_weeks_1              ,
      :principal          =>  @principal_1                ,
      :interest           =>  @interest_1                 , 
      :compulsory_savings        =>  @compulsory_savings_1       , 
      :admin_fee          =>  @admin_fee_1,
      :initial_savings          => @initial_savings_1
    }) 
    
    @total_weeks_2        = 8 
    @principal_2          = BigDecimal('15000')
    @interest_2           = BigDecimal("5000")
    @compulsory_savings_2 = BigDecimal("4000")
    @admin_fee_2          = BigDecimal('10000')
    @initial_savings_2          = BigDecimal('0')

    @group_loan_product_2 = GroupLoanProduct.create_object({
      :name => "Product 2, 800ribu",
      :total_weeks        =>  @total_weeks_2              ,
      :principal          =>  @principal_2                ,
      :interest           =>  @interest_2                 , 
      :compulsory_savings        =>  @compulsory_savings_2       , 
      :admin_fee          =>  @admin_fee_2     ,
      :initial_savings          => @initial_savings_2           
    })
    
    @glp_array  = [@group_loan_product_1, @group_loan_product_2]
    
    @started_at = DateTime.new(2013,10,5,0,0,0)
    @disbursed_at = DateTime.new(2013,10,10,0,0,0)
    @closed_at = DateTime.new(2013,12,5,0,0,0)
    @withdrawn_at = DateTime.new(2013,12,6,0,0,0)
    
    @accounting_closing_datetime = DateTime.new(2014,12,6,0,0,0)
    
    @group_loan = GroupLoan.create_object({
      :name                             => "Group Loan 1" ,
      :number_of_meetings => 3 
    })
    
    Member.all.each do |member|
      glp_index = rand(0..1)
      selected_glp = @glp_array[glp_index]

      GroupLoanMembership.create_object({
        :group_loan_id => @group_loan.id,
        :member_id => member.id ,
        :group_loan_product_id => selected_glp.id
      })
    end
    
    @group_loan.start(:started_at => @started_at) 
    @group_loan.reload 
    
    @group_loan.disburse_loan(:disbursed_at => @disbursed_at)
    
    @first_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC").first
    @first_group_loan_weekly_collection.should be_valid 
    @first_group_loan_weekly_collection.collect(
      {
        :collected_at => DateTime.now 
      }
    )

    @first_group_loan_weekly_collection.is_collected.should be_truthy
    
    @first_glm = @group_loan.active_group_loan_memberships.first 
    @initial_compulsory_savings = @first_glm.total_compulsory_savings
    @first_group_loan_weekly_collection.confirm(:confirmed_at => DateTime.now)
    @first_glm.reload 
    
    @group_loan.group_loan_weekly_collections.order("id ASC").each do |x|
      x.collect(:collected_at => DateTime.now)
      x.confirm(:confirmed_at => DateTime.now)
    end
    
    @group_loan.reload 
    @glm_list = @group_loan.active_group_loan_memberships
    
    @member_compulsory_savings_array = [] 
     @glm_list.each do |glm|
       @member_compulsory_savings_array << [
          glm.member , 
          glm.member.total_savings_account, 
          glm.total_compulsory_savings 
         ]
     end
    @group_loan.close(:closed_at => @closed_at)
    @group_loan.reload 
    
    @group_loan.reload
    @group_loan.withdraw_compulsory_savings(:compulsory_savings_withdrawn_at => @withdrawn_at)
  end
  
  
  it "should close the group_loan" do
    @group_loan.is_closed.should be_truthy
    @group_loan.is_compulsory_savings_withdrawn.should be_truthy
  end
  
  context "create closing" do
    before(:each) do
      @accounting_closing_datetime
      
      @closing = Closing.create_object(
        :end_period => @accounting_closing_datetime,
        :description => "This is the description" 
      )
      
    end
    
    it "should create closing" do
      @closing.errors.size.should == 0 
      @closing.should be_valid
    end
    
    it "should mark closing as first closing " do
      @closing.is_first_closing.should be_truthy 
    end
    
    context "confirming the closing" do
      before(:each) do 
        puts "Start_datetime: #{DateTime.now}"
        @closing.confirm(:confirmed_at => DateTime.now )
        puts "End_Datetime: #{DateTime.now }"
      end
      
      it "should produce valid comb gl" do
        
        
        account_id_list = Account.order("id ASC").all.map{|x| x.id }
        
        valid_comb_account_id_list = ValidComb.where(:closing_id => @closing.id).order("account_id ASC").map {|x| x.account_id }
        
        puts account_id_list
        puts "===>"
        puts valid_comb_account_id_list
        
        Account.count.should == ValidComb.where(:closing_id => @closing.id).count 
      end
    end
  end
end
