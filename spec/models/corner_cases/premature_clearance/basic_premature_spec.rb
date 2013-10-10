# Case 1: member pass away mid shite 

=begin
1. Handle the Premature Clearance case
    1. Member declares premature clearance on week n
    2. It will start to be active on week n + 1. Naturally, there can't be premature clearance 
      on the last week
      since there is no week n+1
    3.
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
    
    @started_at = DateTime.new(2013,10,5,0,0,0)
    @disbursed_at = DateTime.new(2013,10,10,0,0,0)
    
    # start group loan 
    @group_loan.start(:started_at => @started_at)
    @group_loan.reload

    # disburse loan 
    @group_loan.disburse_loan(:disbursed_at => @disbursed_at)
    @group_loan.reload
    
    @first_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC").first
    @second_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC")[1]
    @third_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC")[2]
    @first_group_loan_weekly_collection.should be_valid 
    @first_group_loan_weekly_collection.collect(
      {
        :collected_at => DateTime.now 
      }
    )

    @first_group_loan_weekly_collection.is_collected.should be_true
    # puts "FROM THE SPEC: Gonna confirm first weekly_collection"
    @first_group_loan_weekly_collection.confirm(:confirmed_at => DateTime.now )
    @first_group_loan_weekly_collection.reload
    @second_group_loan_weekly_collection.reload 
    @premature_clearance_glm = @group_loan.active_group_loan_memberships[0] 
    @second_premature_clearance_glm = @group_loan.active_group_loan_memberships[1] 
    @third_premature_clearance_glm = @group_loan.active_group_loan_memberships[2] 
  end
  
  # 
  # it 'should confirm the first group_loan_weekly_collection' do
  #   @first_group_loan_weekly_collection.is_collected.should be_true 
  #   @first_group_loan_weekly_collection.is_confirmed.should be_true 
  # end
  # 
  # 
  # 
  # it 'can only be created if the weekly_collection is not collected and confirmed' do
  #   
  #   @first_gl_pc = GroupLoanPrematureClearancePayment.create_object({
  #     :group_loan_id => @group_loan.id,
  #     :group_loan_membership_id => @premature_clearance_glm.id ,
  #     :group_loan_weekly_collection_id => @first_group_loan_weekly_collection.id   
  #   })
  #   
  #   @first_gl_pc.should_not be_valid 
  #   
  #   
  #   @second_group_loan_weekly_collection.collect(
  #     {
  #       :collected_at => DateTime.now 
  #     }
  #   )
  #   @first_gl_pc = GroupLoanPrematureClearancePayment.create_object({
  #     :group_loan_id => @group_loan.id,
  #     :group_loan_membership_id => @premature_clearance_glm.id ,
  #     :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id   
  #   })
  #   
  #   @first_gl_pc.should_not be_valid
  # end
  # 
  # it 'can only be created if the weekly collection is the first uncollected' do
  #    @first_gl_pc = GroupLoanPrematureClearancePayment.create_object({
  #       :group_loan_id => @group_loan.id,
  #       :group_loan_membership_id => @premature_clearance_glm.id ,
  #       :group_loan_weekly_collection_id => @third_group_loan_weekly_collection.id   
  #     })
  #     
  #     @first_gl_pc.should_not be_valid 
  #     
  # end
  
  it 'should confirm weekly_collection' do
    @first_group_loan_weekly_collection.errors.messages.each {|x| puts  "Msg: #{x}"}
    @first_group_loan_weekly_collection.is_confirmed.should be_true 
  end
  
  it 'should create compulsory savings for each member' do
    # total_compulsory_savings = BigDecimal('0')
    @group_loan.reload 
    @group_loan.group_loan_memberships.joins(:group_loan_product).each do |glm|
      glm.total_compulsory_savings.should == glm.group_loan_product.compulsory_savings
      # total_compulsory_savings += glm.group_loan_product.compulsory_savings
    end
    
    
  end
  
  
  
  context "perform premature clearance" do
    before(:each) do
      @initial_weekly_collection_amount_receivable = @second_group_loan_weekly_collection.amount_receivable
      @first_gl_pc = GroupLoanPrematureClearancePayment.create_object({
        :group_loan_id => @group_loan.id,
        :group_loan_membership_id => @premature_clearance_glm.id ,
        :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id   
      })
      @second_group_loan_weekly_collection.reload 
    end
    
    
    
    # it 'should create the gl_pc' do
    #   @first_gl_pc.should be_valid 
    # end
    
    # it 'should produce the amount: default_payment#amount_receivable + remaining principal payment' do
    #   @first_uncollected_week = @group_loan.first_uncollected_weekly_collection
    #   total_unpaid_week = @group_loan.number_of_collections - @group_loan.first_uncollected_weekly_collection.week_number  
    #   total_principal = @premature_clearance_glm.group_loan_product.principal * total_unpaid_week
    #   expected_premature_clearance_payment = total_principal + 
    #                 @premature_clearance_glm.group_loan_default_payment.amount_receivable 
    #                 # that week where premature clearance is applied has to be paid in full
    #   
    #   # 
    #   # 
    #   # puts "\n\nThe coolest shite"
    #   # puts "==================================\n"
    #   # puts "The uncollected week number: #{@first_uncollected_week.week_number}"
    #   # puts "Number of principal week: #{total_unpaid_week}"
    #   # puts "Total principal: #{total_principal.to_s}"
    #   # puts "The default contribution: #{@premature_clearance_glm.group_loan_default_payment.amount_receivable.to_s}"
    #   # puts "current week payment: #{@premature_clearance_glm.group_loan_product.weekly_payment_amount .to_s}"
    #   # puts "The expected: #{expected_premature_clearance_payment.to_s}"
    #   # puts "The actual: #{@first_gl_pc.amount.to_s}"
    #   
    #   @first_gl_pc.amount.should == expected_premature_clearance_payment
    # end
    
    it 'should increase the amount receivable in the group_loan_weekly_collection' do
      final = @second_group_loan_weekly_collection.amount_receivable 
      diff = final - @initial_weekly_collection_amount_receivable
      diff.should == @first_gl_pc.amount
    end
    
    it 'shoud allow deletion if the weekly_collection has not been confirmed' do
      @first_gl_pc.delete_object
      @first_gl_pc.persisted?.should be_false 
    end
    
    it 'should not allow double creation' do
      @second_gl_pc = GroupLoanPrematureClearancePayment.create_object({
        :group_loan_id => @group_loan.id,
        :group_loan_membership_id => @premature_clearance_glm.id ,
        :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id   
      })
      
      
      @second_gl_pc.should_not be_valid 
    end
    
    it 'should produce weekly_collection with one premature clearance' do
      @second_group_loan_weekly_collection.group_loan_premature_clearance_payments.count.should == 1 
    end
    
    it 'should produce correct premature clearance amount' do
      @second_group_loan_weekly_collection.is_confirmed.should be_false 
      
      # puts "compulsory_savings weekly: #{@premature_clearance_glm.group_loan_product.compulsory_savings}"
      # puts "total_compulsory_savings: #{@premature_clearance_glm.total_compulsory_savings}"
      
      remaining_week = @group_loan.loan_duration - @second_group_loan_weekly_collection.week_number  
      remaining_principal_amount = @premature_clearance_glm.group_loan_product.principal * remaining_week
      
      number_of_weeks_paid = @second_group_loan_weekly_collection.week_number  - 1
      total_compulsory_savings = @premature_clearance_glm.group_loan_product.compulsory_savings * number_of_weeks_paid
      
      total_compulsory_savings.should == @premature_clearance_glm.total_compulsory_savings
      
      puts "weekly compulsory savings : #{@premature_clearance_glm.group_loan_product.compulsory_savings}"
      puts "total compulsory savings: #{@premature_clearance_glm.total_compulsory_savings}"
      puts "remaining principal payable: #{remaining_principal_amount}"
      
      puts "calculated premature clearance amount payable: #{@first_gl_pc.amount}"
      
      current_week_compulsory_savings = @premature_clearance_glm.group_loan_product.compulsory_savings
      
      @first_gl_pc.amount.should == remaining_principal_amount - 
                      @premature_clearance_glm.total_compulsory_savings -   # the total compulsory savings hasn't included the current weel
                      current_week_compulsory_savings
    end
    
   

    context "weekly_collection.confirm" do
      before(:each) do
        @second_group_loan_weekly_collection.collect(
          {
            :collected_at => DateTime.now 
          }
        )
        
        @second_group_loan_weekly_collection.confirm(:confirmed_at => DateTime.now) 
        @premature_clearance_glm.reload 
        @first_gl_pc.reload 
      end
      
      it 'should confirm the clearance' do
        @first_gl_pc.is_confirmed.should be_true 
      end
      
      it 'should deactivate the membership' do
        @premature_clearance_glm.is_active.should be_false
        @premature_clearance_glm.deactivation_case.should == GROUP_LOAN_DEACTIVATION_CASE[:premature_clearance]
        @premature_clearance_glm.deactivation_week_number.should == @second_group_loan_weekly_collection.week_number + 1 
      end
      
      it 'should increase the amount_receivable in week 2 by premature_clearance amount' do
        remaining_week = @group_loan.loan_duration - @premature_clearance_glm.deactivation_week_number + 1 
        premature_clearance_amount = @first_gl_pc.amount
         
        base_collection = BigDecimal('0')
        @group_loan.group_loan_memberships.each do |glm|
          base_collection += glm.group_loan_product.weekly_payment_amount 
        end
        @second_group_loan_weekly_collection.amount_receivable.should == base_collection + premature_clearance_amount 
      end
      
      it 'should reduce the amount_receivable in week 3' do
        
        base_collection = BigDecimal('0')
        @group_loan.group_loan_memberships.each do |glm|
          next if glm.id == @premature_clearance_glm.id 
          base_collection += glm.group_loan_product.weekly_payment_amount 
        end
        @third_group_loan_weekly_collection.amount_receivable.should == base_collection 
      end
      
      
       
    end
      
  
  end
end

