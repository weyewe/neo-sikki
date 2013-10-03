require 'spec_helper'

describe GroupLoan do
  
  before(:each) do
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
    
    @closed_at = DateTime.new(2013,12,5,0,0,0)
    @withdrawn_at = DateTime.new(2013,12,6,0,0,0)
  end
  
  
=begin
  Create Member 
  Create GroupLoanProduct
  Create GroupLoanMembership 
  
  Start Loan => Cashier has to prepare the $$ to be disbursed, and mark it as Cash prepared. 
    Receipt of cash passed from cashier to loan officer is done offline. 
    
    # DISBURSEMENT process is done offline. 
    # computer only wants to know the amount of $$ disbursed. 
  Trigger loan disbursement 
    Loan Officer come back with the contract + The list of members whose loan is disbursed + the excess 
      cash undisbursed. The excess cash must be equal to the sum of money allocated to the member
      not present @loan disbursement. This excess money will go to the moneyshelf. => Done. 
      
      Later, when they are about to bank the excess, use normal accounting procedure to move from
      moneyshelf to bank account 
      
  Weekly Payment Collection
    
  Close the group loan 
=end
  context "normal operation: no corner cases, no update, uber-ideal case" do
    before(:each) do
      
      @group_loan = GroupLoan.create_object({
        :name                             => "Group Loan 1" ,
        :number_of_meetings => 3 
      })
      
    end
    
    it 'should produce group_loan' do
      @group_loan.should be_valid 
    end
    
    context "create group loan membership" do
      
      before(:each) do 
        Member.all.each do |member|
          glp_index = rand(0..1)
          selected_glp = @glp_array[glp_index]

          GroupLoanMembership.create_object({
            :group_loan_id => @group_loan.id,
            :member_id => member.id ,
            :group_loan_product_id => selected_glp.id
          })
        end
      end
      
      it 'should have equal total count of glm and member' do
        @group_loan.group_loan_memberships.count.should == Member.count
      end
      
      context "starting the group_loan" do
        before(:each) do
          @group_loan.start 
          @group_loan.reload 
        end
        
        it 'should have started group loan' do
          @group_loan.is_started.should be_true 
        end
        
        it 'should manifest the number of collections' do
          @group_loan.number_of_collections.should == @group_loan.loan_duration 
        end
        
        context "execute loan disbursement" do
          before(:each) do
            @group_loan.disburse_loan 
          end
          
          it 'should be marked as loan disbursed' do
            @group_loan.is_loan_disbursed.should be_true 
          end
          
          it 'should have created N GroupLoanDisbursement' do
            @group_loan.group_loan_disbursements.count.should == GroupLoanDisbursement.all.count 
          end
          
          it 'should have created N GroupLoanWeeklyCollection' do
            @group_loan.group_loan_weekly_collections.count.should == @group_loan.number_of_collections
          end
          
          it 'should be allowed to mark GroupLoanWeeklyCollection as collected' do
            @first_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC").first
            @first_group_loan_weekly_collection.should be_valid 
            @first_group_loan_weekly_collection.collect(
              {
                :collection_datetime => DateTime.now 
              }
            )
            
            @first_group_loan_weekly_collection.is_collected.should be_true 
          end
          
          it 'should not be allowed to skip week in the GroupLoanWeeklyCollection' do 
            @second_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC")[1]
            @second_group_loan_weekly_collection.should be_valid 
            @second_group_loan_weekly_collection.collect(
              {
                :collection_datetime => DateTime.now 
              }
            )
            
            @second_group_loan_weekly_collection.is_collected.should be_false
            @second_group_loan_weekly_collection.errors.size.should_not == 0
          end
          
          
          context "weekly payment collection: 1 week" do
            before(:each) do
              @first_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC").first
              @first_group_loan_weekly_collection.should be_valid 
              @first_group_loan_weekly_collection.collect(
                {
                  :collection_datetime => DateTime.now 
                }
              )

              @first_group_loan_weekly_collection.is_collected.should be_true
              
              @first_glm = @group_loan.active_group_loan_memberships.first 
              @initial_compulsory_savings = @first_glm.total_compulsory_savings
              @first_group_loan_weekly_collection.confirm
              @first_glm.reload 
               
            end
            
            it 'should confirm the first group_loan_weekly_collection' do
              @first_group_loan_weekly_collection.is_confirmed.should be_true 
            end
            
            it 'should have increased group loan total compulsory savings' do
              total_compulsory_savings = BigDecimal('0')
              @group_loan.active_group_loan_memberships.each do |x|
                total_compulsory_savings += x.group_loan_product.compulsory_savings
              end
              
              @group_loan.total_compulsory_savings.should == total_compulsory_savings
            end
            
            it 'should have increased the compulsory savings'  do
              @final_compulsory_savings = @first_glm.total_compulsory_savings
              diff = @final_compulsory_savings - @initial_compulsory_savings
              diff.should == @first_glm.group_loan_product.compulsory_savings 
            end
            
            it 'should give the 2nd week collection for group_loan#first_uncollected_weekly_collection' do
              second_group_loan_weekly_collection = @group_loan.group_loan_weekly_collections.order("id ASC")[1]
              @group_loan.first_uncollected_weekly_collection.id.should == second_group_loan_weekly_collection.id 
            end
            
            
          end
          
          context "closing weekly loan: do all weekly payment collection" do
            before(:each) do
              @group_loan.group_loan_weekly_collections.order("id ASC").each do |x|
                x.collect(:collection_datetime => DateTime.now)
                x.confirm 
              end
              
              @group_loan.reload 
            end
            
            it 'should have confirmed all group_loan weekly collections' do
              @group_loan.group_loan_weekly_collections.where(:is_collected => true, :is_confirmed => true).count.should == @group_loan.number_of_collections 
            end
            
            it 'should give nil to the next uncollected group_loan_weekly_collection' do
              @group_loan.first_uncollected_weekly_collection.should be_nil 
            end
            
            it 'should not allow compulsory savings withdrawal before closing group loan' do
              @group_loan.withdraw_compulsory_savings(:compulsory_savings_withdrawn_at => @withdrawn_at)
              @group_loan.errors.size.should_not == 0  
            end
            
            context 'closing group loan' do
              before(:each) do
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
              end
              
              it 'should deactivate all glm' do
                @glm_list.each do |glm|
                  glm.reload
                  glm.is_active.should be_false 
                  glm.deactivation_case.should == GROUP_LOAN_DEACTIVATION_CASE[:finished_group_loan]
                end
              end
              
              it 'should have increased the savings_account by the amount of compulsory_savings' do
                @member_compulsory_savings_array.each do |pair|
                  member = pair.first
                  initial_savings =  pair[1]
                  total_compulsory_savings = pair.last 
                  
                  member.reload 
                  final_savings = member.total_savings_account 
                  diff = final_savings - initial_savings 
                  diff.should == BigDecimal('0')
                end
              end
              
              it 'should NOT produce 0 for total_compulsory_savings' do
                
                # it is the historical data... 
                @glm_list.each do |glm|
                  glm.reload
                  # puts "the total compulsory savings: #{glm.total_compulsory_savings.to_s} "
                  glm.total_compulsory_savings.should_not == BigDecimal('0')
                end
                
              end
              
              context 'withdrawing the remaining compulsory savings' do
                before(:each) do
                  @group_loan.reload
                  @group_loan.withdraw_compulsory_savings(:compulsory_savings_withdrawn_at => @withdrawn_at)
                end
                
                it 'should withdraw compulsory savings' do
                  @group_loan.is_compulsory_savings_withdrawn .should be_true 
                end
                
                
                it 'should create journal posting'
              end
              
            end
          end
        end
        
        
      end
      
      
    end
    
  end
end
