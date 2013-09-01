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
    
    # start group loan 
    @group_loan.start 
    @group_loan.reload

    # disburse loan 
    @group_loan.disburse_loan 
    @group_loan.reload
    
    @first_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC").first
    @first_group_loan_weekly_collection.should be_valid 
    @first_group_loan_weekly_collection.collect(
      {
        :collection_datetime => DateTime.now 
      }
    )

    @first_group_loan_weekly_collection.is_collected.should be_true
    @first_group_loan_weekly_collection.confirm
    @first_group_loan_weekly_collection.reload
    
  end
  
  
  it 'should confirm the first group_loan_weekly_collection' do
    @first_group_loan_weekly_collection.is_collected.should be_true 
    @first_group_loan_weekly_collection.is_confirmed.should be_true 
  end
  
  context "a member  run away ( week 2 ) "  do
    before(:each) do
      @run_away_glm = @group_loan.active_group_loan_memberships.first 
      @run_away_member = @run_away_glm.member 
      @initial_active_glm_count = @group_loan.active_group_loan_memberships.count 
      @first_week_amount_receivable=   @first_group_loan_weekly_collection.amount_receivable
      
      @run_away_member.mark_as_run_away
      @group_loan.reload 
      @run_away_glm.reload 
      @second_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC")[1]
    end
    
    it 'should create one DeceasedPrincipalReceivable' do
      GroupLoanRunAwayReceivable.count.should == 1 
      a = GroupLoanRunAwayReceivable.first 
      # by default, weekly 
      a.payment_case.should == GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly]
      
      @run_away_glm.reload 
      @run_away_glm.is_active.should be_false 
      @run_away_glm.deactivation_week_number.should == @second_group_loan_weekly_collection.week_number
      @run_away_glm.deactivation_case.should == GROUP_LOAN_DEACTIVATION_CASE[:run_away]
    end
    
    it 'should extract the glm that is active at that particular week' do
      week_2_active_glm_count = @second_group_loan_weekly_collection.active_group_loan_memberships.count 
      week_2_active_glm_count.should == (@initial_active_glm_count - 1 ) 
    end
    
    it 'should reduce the active_glm count' do
      @final_active_glm_count = @group_loan.active_group_loan_memberships.count
      diff = @initial_active_glm_count - @final_active_glm_count
      diff.should == 1 
    end
    
    it 'should not contain the run away glm in the active_glm' do 
      @active_glm_id_list = @group_loan.active_group_loan_memberships.map{|x| x.id }
      @active_glm_id_list.include?(@run_away_glm.id).should be_false 
    end
    
     #    
     # context "pay at the same week run_away_receivable" do
     #   before(:each) do
     #   end
     #   
     #   it 'should NOT create diff from first week amount receivable' do
     #     diff = @first_week_amount_receivable -  @second_group_loan_weekly_collection.amount_receivable
     #     diff.should  == @run_away_glm.group_loan_product.weekly_payment_amount
     #   end
     #   
     #   it 'should NOT reduce the amount receivable(same from collection#1)' do
     # 
     # 
     #     @first_collection_amount  = @first_group_loan_weekly_collection.amount_receivable
     #     @second_collection_amount = @second_group_loan_weekly_collection.amount_receivable
     # 
     #     diff = @first_collection_amount - @second_collection_amount
     #     diff.should == @run_away_glm.group_loan_product.weekly_payment_amount
     #   end
     #   
     # end
     # 
     # context "pay at the end of cycle run_away_receivable" do
     #   before(:each) do
     #   end
     #   
     #   it 'should  create diff from first week amount receivable' do
     #     diff = @first_week_amount_receivable -  @second_group_loan_weekly_collection.amount_receivable
     #     diff.should  == @run_away_glm.group_loan_product.weekly_payment_amount
     #   end
     #   
     #   it 'should  reduce the amount receivable(same from collection#1)' do
     # 
     # 
     #     @first_collection_amount  = @first_group_loan_weekly_collection.amount_receivable
     #     @second_collection_amount = @second_group_loan_weekly_collection.amount_receivable
     # 
     #     diff = @first_collection_amount - @second_collection_amount
     #     diff.should == @run_away_glm.group_loan_product.weekly_payment_amount
     #   end
     #   
     # end
     #   
    
    
    
    
    # 
    # context "perform collection and confirmation" do
    #   before(:each) do
    #     @second_group_loan_weekly_collection.collect(:collection_datetime => DateTime.now)
    #     @second_group_loan_weekly_collection.confirm
    #   end
    #   
    #   it 'should not create GroupLoanWeeklyPayment to the deceased member' do
    #     GroupLoanWeeklyPayment.where(:group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id,
    #             :group_loan_membership_id => @run_away_glm.id ).count.should == 0 
    #   end
    # end
    
    # context "finishing the payment collection cycle" do
    #   before(:each) do
    #     @group_loan.group_loan_weekly_collections.order("id ASC").each do |x|
    #       next if x.is_collected? and x.is_confirmed? 
    #       
    #       x.collect(:collection_datetime => DateTime.now)
    #       x.confirm 
    #     end
    #     
    #     @group_loan.reload
    #     @group_loan.close
    #     @group_loan.reload
    #     @second_group_loan_weekly_collection.reload 
    #     @first_group_loan_weekly_collection.reload 
    #   end
    #   
    #   it 'should close the group loan' do
    #      @group_loan.is_closed.should be_true 
    #    end
    #   
    #   it 'should give the correct number of active group_loan_membership (though it is closed)' do
    #     @group_loan.active_group_loan_memberships.count.should == @initial_active_glm_count -1 # (1 deceased)
    #     @group_loan.group_loan_memberships.where(:is_active => true).count.should == 0 
    #     
    #     week_2_active_glm_count = @second_group_loan_weekly_collection.active_group_loan_memberships.count 
    #     week_2_active_glm_count.should == (@initial_active_glm_count - 1 )
    #     
    #     week_1_active_glm_count = @first_group_loan_weekly_collection.active_group_loan_memberships.count 
    #     week_1_active_glm_count.should == (@initial_active_glm_count  )
    #     
    #     
    #   end
    # end
  end
  
  
  
   
  
end

