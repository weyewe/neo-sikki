# Case 1: Complex case: mixing run away and clearance

=begin
1. Handle the UncollectibleWeekly  + PrematureClearancePayment
  Scenario: week 1 everyone pays normal 
            week 2, member 1 declare  run away 
            week 3, member 2 declare premature_clearance
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
    @second_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC")[1]
    @third_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC")[2]
    @fourth_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC")[3]
    @first_group_loan_weekly_collection.should be_valid 
    @first_group_loan_weekly_collection.collect(
      {
        :collection_datetime => DateTime.now 
      }
    )

    @first_group_loan_weekly_collection.is_collected.should be_true
    @first_group_loan_weekly_collection.confirm
    @first_group_loan_weekly_collection.reload
    @second_group_loan_weekly_collection.reload 
    @first_glm = @group_loan.active_group_loan_memberships[0] 
    @second_glm = @group_loan.active_group_loan_memberships[1] 
    @third_glm = @group_loan.active_group_loan_memberships[2] 
  end
  
  
  it 'should confirm the first group_loan_weekly_collection' do
    @first_group_loan_weekly_collection.is_collected.should be_true 
    @first_group_loan_weekly_collection.is_confirmed.should be_true 
  end
  
  context "create 1 run_away in the week 2" do
    before(:each) do
      @initial_glm_count = @group_loan.active_group_loan_memberships.count 
      @run_away_member = @first_glm.member 
      @run_away_member.mark_as_run_away 
      
      @second_group_loan_weekly_collection.collect(
        {
          :collection_datetime => DateTime.now 
        }
      )
      
      @second_group_loan_weekly_collection.confirm 
      @group_loan.reload 
      @first_run_away = GroupLoanRunAwayReceivable.first 
    end
    
    it 'should produce 1 run away' do
      GroupLoanRunAwayReceivable.count.should == 1 
      @first_run_away.should be_valid 
      @first_run_away.group_loan_membership_id.should == @first_glm.id 
      @first_run_away.payment_case.should == GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly]
    end
    
    it 'should deactivate the glm' do
      @final_glm_count = @group_loan.active_group_loan_memberships.count 
      
      diff = @initial_glm_count - @final_glm_count
      diff.should == 1 
    end
    
    it 'should not update the amount of default_payment.amount_receivable' do
      @group_loan.active_group_loan_memberships.each do |glm|
        next if glm.id == @first_glm.id 
        glm.group_loan_default_payment.amount_receivable.should == BigDecimal('0')
      end
    end
  end  
  
  
  context 'switch run away payment case to end_of_cycle' do
    before(:each) do
      
     
      
      @initial_glm_count = @group_loan.active_group_loan_memberships.count 
      @run_away_member = @first_glm.member 
      @run_away_member.mark_as_run_away
      
      @first_run_away = GroupLoanRunAwayReceivable.first 
       
      @first_run_away.set_payment_case( {
        :payment_case =>  GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:end_of_cycle]
      } ) 
      
      @group_loan.reload 
    end
    
    it 'should update the payment case' do 
      @first_run_away.errors.size.should == 0 
      @first_run_away.payment_case.should ==   GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:end_of_cycle]
    end
    
    it 'should deactivate one member' do
      @group_loan.active_group_loan_memberships.count.should == @initial_glm_count - 1 
    end
    
    it 'should update default payment total amount' do
      @group_loan.default_payment_total_amount.should == @first_run_away.amount_receivable 
    end
    
    it 'should update the amount of dfeault payment' do
      @group_loan.active_group_loan_memberships.each do |glm|
        next if glm.id == @first_glm.id 
        glm.group_loan_default_payment.amount_receivable.should_not == BigDecimal('0')
      end
      
      amount_to_be_split = @first_run_away.amount_receivable 
      
      splitted_amount = amount_to_be_split/@group_loan.active_group_loan_memberships.count 
      
      rounded_up = GroupLoan.rounding_up(splitted_amount, DEFAULT_PAYMENT_ROUND_UP_VALUE)
      # puts "\n\n ================== The Eval ============== \n\n"
      # 
      # 
      # puts "amount_to_be_split: #{amount_to_be_split.to_s}"
      # puts "default_payment_total_amount: #{@group_loan.default_payment_total_amount.to_s}"
      # puts "splitted_amount: #{splitted_amount}"
      # puts "\nrounded up amount: #{rounded_up.to_s}\n"
      # puts "active_glm_count: #{@group_loan.active_group_loan_memberships.count }"
      # 
      # puts "==========> =========> the amount_receivable"
      # 
      @group_loan.active_group_loan_memberships.each do |glm|
        next if glm.id == @first_glm.id 
        
        # puts "glm #{glm.id}, amount_receivable: #{glm.group_loan_default_payment.amount_receivable.to_s}"
      
        glm.group_loan_default_payment.amount_receivable.should  == rounded_up
      end
      
    end
  end
  
  
  
end

