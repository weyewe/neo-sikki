# Case 1: Complex case: mixing uncollectible and clearance

=begin
1. Handle the UncollectibleWeekly  + PrematureClearancePayment
  Scenario: week 1 everyone pays normal 
            week 2, member 1 declare can't pay => uncollectible
            week 3, member 2 declare premature_clearance
            week 4, member 3 declare can't pay => uncollectible 
            
            # perform the normal payment all the way 
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
  
  context "create 1 uncollectible in the week 2" do
    before(:each) do
      @first_gl_wu = GroupLoanWeeklyUncollectible.create_object({
        :group_loan_id => @group_loan.id,
        :group_loan_membership_id => @first_glm.id ,
        :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id   
      })
      
      @second_group_loan_weekly_collection.collect(
        {
          :collection_datetime => DateTime.now 
        }
      )
      
      @second_group_loan_weekly_collection.confirm 
      @group_loan.reload 
    end
    
    it 'should confirm the weekly collection' do
      @second_group_loan_weekly_collection.is_confirmed.should be_true 
    end
    
    it 'should have normal amount receivable minus the weekly_payment of uncollectible member' do
      expected_amount = BigDecimal('0')
      @group_loan.active_group_loan_memberships.each do |glm|
        next if glm.id == @first_glm.id 
        expected_amount += glm.group_loan_product.weekly_payment_amount 
      end
      @second_group_loan_weekly_collection.amount_receivable.should == expected_amount
    end
    
    it 'should create default_payment.amount_receivable for all members' do
      total_amount = @first_glm.group_loan_product.weekly_payment_amount 
      splitted_amount = total_amount/@group_loan.active_group_loan_memberships.count 
      
      amount_per_member = GroupLoan.rounding_up(splitted_amount, DEFAULT_PAYMENT_ROUND_UP_VALUE)
      
      @group_loan.active_group_loan_memberships.joins(:group_loan_default_payment).each do |glm|
        glm.group_loan_default_payment.amount_receivable.should == amount_per_member
      end
    end
    
    # context "declare 1 member premature clearance on week 2" do
    #   before(:each) do
    #     @sum_of_all_member_payments = BigDecimal('0') 
    #     
    #     @group_loan.active_group_loan_memberships.each do |glm|
    #       @sum_of_all_member_payments += glm.group_loan_product.weekly_payment_amount 
    #     end
    #     
    #     @gl_pc = GroupLoanPrematureClearancePayment.create_object({
    #       :group_loan_id => @group_loan.id,
    #       :group_loan_membership_id => @second_glm.id ,
    #       :group_loan_weekly_collection_id => @third_group_loan_weekly_collection.id   
    #     })
    #     
    #     @third_group_loan_weekly_collection.collect(
    #       {
    #         :collection_datetime => DateTime.now 
    #       }
    #     )
    #     @third_group_loan_weekly_collection.confirm 
    #   end
    #   
    #   it 'should give amount receivable in full + the default amount from premature_clearance member' do
    #     expected_amount_receivable = @sum_of_all_member_payments  + @second_glm.group_loan_default_payment.amount_receivable 
    #     
    #     expected_amount_receivable.should == @third_group_loan_weekly_collection.amount_receivable 
    #   end
    # end
    
  end # end of week 2 
  
  
end

