# Case 1: member run away mid-cycle 

=begin
1. Handle the Run Away case
     Branch Submit the form (written + double signed by Loan Officer + Branch Manager ), 
      so that it will be deactivated by the central command.  
      => the runaway member will be blocked from all group loan product 

     For each GroupLoanProduct that are currently active, the branch
     has to submit the payment decision: whether default resolved weekly, or and the end-of-cycle

     1. Weekly
        There is extra payment to be made (total = all active members + run away member)
        In the payment details: list all active member's payment + entry for the run away member. 
        That's it.  => compose reports 


     2. End of cycle
          In the weekly payment, ignore the extra payment caused by the run away member
          At the end of the cycle, deduct all active's compulsory savings by the amount debted.  
          
          If there is excess, 

=end

require 'spec_helper'

describe GroupLoan do
  
  before(:each) do
    # Account.create_base_objects
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

    @group_loan = GroupLoan.create_object({
      :name                             => "Group Loan 1" ,
      :number_of_meetings => 3 
    })
    
    # create GLM
    Member.all.each do |member|
      glp_index = rand(0..1)
      selected_glp = @glp_array[glp_index]

      GroupLoanMembership.create_object({
        :group_loan_id => @group_loan.id,
        :member_id => member.id ,
        :group_loan_product_id => selected_glp.id
      })
    end
    
    @started_at = DateTime.new(2013,10,5,0,0,0)
    @disbursed_at = DateTime.new(2013,10,10,0,0,0)
    
    # start group loan 
    @group_loan.start(:started_at =>@started_at)
    @group_loan.reload

    # disburse loan 
    @group_loan.disburse_loan(:disbursed_at => @disbursed_at)
    @group_loan.reload
    
    @first_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC").first
    @first_group_loan_weekly_collection.should be_valid 
    @first_group_loan_weekly_collection.collect(
      {
        :collected_at => DateTime.now 
      }
    )

    @first_group_loan_weekly_collection.is_collected.should be_truthy
    @first_group_loan_weekly_collection.confirm(:confirmed_at => DateTime.now )
    @first_group_loan_weekly_collection.reload
    @closed_at = DateTime.new(2013,12,5,0,0,0)
  end
  
  
  it 'should confirm the first group_loan_weekly_collection' do
    @first_group_loan_weekly_collection.is_collected.should be_truthy 
    @first_group_loan_weekly_collection.is_confirmed.should be_truthy 
  end
  
  context "a member  run away ( week 2 ) "  do
    before(:each) do
      @run_away_glm = @group_loan.active_group_loan_memberships.first 
      @run_away_member = @run_away_glm.member 
      @initial_active_glm_count = @group_loan.active_group_loan_memberships.count 
      @first_week_amount_receivable=   @first_group_loan_weekly_collection.amount_receivable
      
      # @initial_group_loan_run_away_amount_receivable = @group_loan.run_away_amount_receivable
      
      @run_away_member.mark_as_run_away(:run_away_at => DateTime.now)
      @group_loan.reload 
      @run_away_glm.reload 
      @second_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC")[1]
      @third_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC")[2]
      
      @second_group_loan_weekly_collection.collect(:collected_at => DateTime.now)
      @second_group_loan_weekly_collection.confirm(:confirmed_at => DateTime.now)
    end
    
    
    
    context "creating collection and confirm for week 3" do
      before(:each) do
        @third_group_loan_weekly_collection.collect(:collected_at => DateTime.now)
        @third_group_loan_weekly_collection.confirm(:confirmed_at => DateTime.now)
        @second_group_loan_weekly_collection.reload
      end
      
      it "should confirm week 2" do
        @second_group_loan_weekly_collection.is_confirmed.should be_truthy
      end
      
      it "should create transaction to reduce bad debt allowance since there is weekly payment" do
        
    
        TransactionData.where(
          :transaction_source_id => @second_group_loan_weekly_collection.id , 
          :transaction_source_type => @second_group_loan_weekly_collection.class.to_s ,
          :code => TRANSACTION_DATA_CODE[:group_loan_run_away_in_cycle_clearance]
        ).count.should ==  1
      end
      
      
    end
     
    
    
  end
  
  
  
   
  
end

