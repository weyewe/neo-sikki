# Case 1: member pass away mid shite 

=begin
1. Handle the UncollectibleWeekly Payment Case 
    Branch Submit the form (written + double signed by Loan Officer + Branch Manager ), so that it will be deactivated by the central command. 
 
    When it is not collected, just let it go. Mark it as a bad debt material. 
    
    When it is payable on the additional default payment: do it. 
    
    Since it is a black swan, so put a heavy punishment on that. We don't want that to happen anyway. 

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
    @uncollectible_glm = @group_loan.active_group_loan_memberships[0] 
    @second_uncollectible_glm = @group_loan.active_group_loan_memberships[1] 
    @third_uncollectible_glm = @group_loan.active_group_loan_memberships[2] 
  end
  
  
  it 'should confirm the first group_loan_weekly_collection' do
    @first_group_loan_weekly_collection.is_collected.should be_true 
    @first_group_loan_weekly_collection.is_confirmed.should be_true 
  end
  
  it 'should create uncollectible_weekly_payment for first due weekly_collection' do
    @gl_wu =GroupLoanWeeklyUncollectible.create_object({
      :group_loan_id => @group_loan.id,
      :group_loan_membership_id => @uncollectible_glm.id ,
      :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id 
    })
    
    @gl_wu.should be_valid 
  end
  
  it 'should not create uncollectible_weekly_payment for the confirmed week' do
    @gl_wu = GroupLoanWeeklyUncollectible.create_object({
      :group_loan_id => @group_loan.id,
      :group_loan_membership_id => @uncollectible_glm.id ,
      :group_loan_weekly_collection_id => @first_group_loan_weekly_collection.id  
    })
    
    @gl_wu.should_not be_valid
  end
  
  it 'should not create double uncollectible weekly payment' do
    @gl_wu =GroupLoanWeeklyUncollectible.create_object({
      :group_loan_id => @group_loan.id,
      :group_loan_membership_id => @uncollectible_glm.id ,
      :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id  
    })
    
    @gl_wu.should be_valid
    
    @gl_wu =GroupLoanWeeklyUncollectible.create_object({
      :group_loan_id => @group_loan.id,
      :group_loan_membership_id => @uncollectible_glm.id ,
      :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id  
    })
    
    @gl_wu.should_not  be_valid
  end
  
  it 'should not create uncollectible_weekly_payment for the non first uncollected week' do
    @gl_wu = GroupLoanWeeklyUncollectible.create_object({
      :group_loan_id => @group_loan.id,
      :group_loan_membership_id => @uncollectible_glm.id ,
      :group_loan_weekly_collection_id => @third_group_loan_weekly_collection.id  
    })
    
    @gl_wu.should_not be_valid
  end
  
  context "updating the uncollectible's glm id" do
    before(:each) do
      @first_gl_wu = GroupLoanWeeklyUncollectible.create_object({
        :group_loan_id => @group_loan.id,
        :group_loan_membership_id => @uncollectible_glm.id ,
        :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id   
      })
      
      @second_gl_wu = GroupLoanWeeklyUncollectible.create_object({
        :group_loan_id => @group_loan.id,
        :group_loan_membership_id => @second_uncollectible_glm.id ,
        :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id  
      })
    end
    
    it 'should create first_gl_wu and second_gl_wu ' do
      @first_gl_wu.should be_valid 
      @second_gl_wu.should be_valid 
    end
    
    it 'should allow update to the second_gl_wu' do
      @second_gl_wu.update_object({
        :group_loan_id => @group_loan.id,
        :group_loan_membership_id => @third_uncollectible_glm.id ,
        :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id 
      })
      
      @second_gl_wu.should be_valid 
       
       
      @second_gl_wu.group_loan_membership.id.should == @third_uncollectible_glm.id
    end
    
    it 'should not allow update to the first_gl_wu (create 2 uncollectibles with equal glm_id)' do
      @second_gl_wu.update_object({
        :group_loan_id => @group_loan.id,
        :group_loan_membership_id => @uncollectible_glm.id ,
        :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id 
      })
      
      @second_gl_wu.should_not be_valid 
    end
  end
  
  
  context "create one uncollectible: impact on the weekly_collection amount" do
    before(:each) do
      @initial_amount_receivable = @second_group_loan_weekly_collection.amount_receivable
      
      @initial_extract_uncollectable_weekly_payment_amount = @second_group_loan_weekly_collection.extract_uncollectable_weekly_payment_amount
      @first_gl_wu = GroupLoanWeeklyUncollectible.create_object({
        :group_loan_id => @group_loan.id,
        :group_loan_membership_id => @uncollectible_glm.id ,
        :group_loan_weekly_collection_id => @second_group_loan_weekly_collection.id   
      })
      @group_loan.reload 
    end
    
    it 'should produce 0 for the initial_uncollectable_payment_amount' do
      @initial_extract_uncollectable_weekly_payment_amount.should == BigDecimal('0')
    end
    
    it 'should create valid gl_wu' do
      @first_gl_wu.should be_valid 
    end
    
    it 'should reduce the weekly_collection amount' do
      final_amount_receivable = @second_group_loan_weekly_collection.amount_receivable
      diff = @initial_amount_receivable - final_amount_receivable
      diff.should == @uncollectible_glm.group_loan_product.weekly_payment_amount
    end
    
    it 'should not update default_payment amount_receivable pre-weekly_collection confirmation' do
      @group_loan.active_group_loan_memberships.joins(:group_loan_default_payment).each do |glm|
        glm.group_loan_default_payment.amount_receivable.should == BigDecimal('0')
      end
    end
    
    context "confirming the weekly_collection with group_loan_weekly_uncollectible" do
      before(:each) do
        @second_group_loan_weekly_collection.collect({
          :collection_datetime => DateTime.now 
        })
        
        @second_group_loan_weekly_collection.confirm 
        @group_loan.reload 
      end
      
      it 'should confirm the second_group_loan_weekly_collection' do
        @second_group_loan_weekly_collection.is_confirmed.should be_true 
      end
      
      it 'should update the group_loan_default_payment amount_receivable' do
        @group_loan.active_group_loan_memberships.joins(:group_loan_default_payment).each do |glm|
          glm.group_loan_default_payment.amount_receivable.should_not == BigDecimal('0')
        end
      end
      
      it 'should produce equal splitting' do
        # GroupLoan.rounding_up(amount,  nearest_amount ) 
        total_default_amount = @uncollectible_glm.group_loan_product.weekly_payment_amount 
        share_per_member= total_default_amount/@group_loan.active_group_loan_memberships.count 
        
        expected_amount_receivable  = GroupLoan.rounding_up( share_per_member, DEFAULT_PAYMENT_ROUND_UP_VALUE)
        
        @group_loan.active_group_loan_memberships.joins(:group_loan_default_payment).each do |glm|
          glm.group_loan_default_payment.amount_receivable.should == expected_amount_receivable
        end
      end
     
    end
    
    
  end
  
  
  
  
  
end

