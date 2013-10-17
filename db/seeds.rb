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
  :works => {
    :index => true, 
    :create => true,
    :update => true,
    :destroy => true,
    :work_reports => true ,
    :project_reports => true ,
    :category_reports => true 
  },
  :projects => {
    :search => true 
  },
  :categories => {
    :search => true 
  }
}

data_entry_role = Role.create!(
  :name        => ROLE_NAME[:data_entry],
  :title       => 'Data Entry',
  :description => 'Role for data_entry',
  :the_role    => role.to_json
)



if Rails.env.development?

=begin
  CREATING THE USER 
=end

  admin = User.create_main_user(  :name => "Admin", :email => "admin@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 
  admin.set_as_main_user


  data_entry1 = User.create_object(:name => "Data Entry", :email => "data_entry1@gmail.com", 
                :password => 'willy1234', 
                :password_confirmation => 'willy1234',
                :role_id => data_entry_role.id )
              
  data_entry1.password = 'willy1234'
  data_entry1.password_confirmation = 'willy1234'
  data_entry1.save

  data_entry2 = User.create_object(:name => "Data Entry", :email => "data_entry2@gmail.com", 
                :password => 'willy1234', 
                :password_confirmation => 'willy1234',
                :role_id => data_entry_role.id )
              
  data_entry2.password = 'willy1234'
  data_entry2.password_confirmation = 'willy1234'
  data_entry2.save


  user_array = [admin, data_entry1, data_entry2]



=begin
  CREATING THE Member 
=end
  member_array = []
  (1..80).each do |number|
    member = Member.create_object({
      :name =>  "Member #{number}",
      :address => "Address alamat #{number}" ,
      :id_number => "342432#{number}"
    })
    member_array << member 
  end

 
  # customer_array = [cust_1, cust_2, cust_3, cust_4] 
  
  member_array = Member.all 

=begin
  Create GroupLoanProduct
=end

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
  
  glp_array = [
    @group_loan_product_1,
    @group_loan_product_2
    ]

=begin
  Create seed group_loan 
=end

  @group_loan_1 = GroupLoan.create_object({
    :name                             => "Group Loan 1" ,
    :number_of_meetings => 3 
  })
  
  @group_loan_2 = GroupLoan.create_object({
    :name                             => "Group Loan 2" ,
    :number_of_meetings => 5
  })
  
   
  
  
=begin
  Create seed glm
=end
  # Member.order("ASC")limit(10).
  member_array[0..9].each do |member|
    selected_index=  rand(0..1)
    selected_glp = glp_array[selected_index]
    GroupLoanMembership.create_object({
      :group_loan_id => @group_loan_1.id,
      :member_id => member.id ,
      :group_loan_product_id => selected_glp.id
    })
  end
  
  
=begin
  Start the group loan 
=end
  @group_loan_1.start(:started_at => DateTime.now )
  
  @group_loan_1.disburse_loan(:disbursed_at => DateTime.now )
  
  @deceased_glm = @group_loan_1.group_loan_memberships.first 
  @deceased_member = @deceased_glm.member 
  
  @deceased_member.mark_as_deceased(:deceased_at => DateTime.now )
  
  
  
  
  
  
  
  

  def make_date(*args)
    now = DateTime.now  
  
    d = ( args[0] || 0 )
    h = (args[1]  || 0)  
    m = (args[2] || 0)  
    s = (args[3] || 0)  
  
  
    target_date = ( now  + d.days + h.hours + m.minutes + s.seconds   ) .new_offset( Rational(0,24) ) 
  
    adjusted_date = DateTime.new( target_date.year, target_date.month, target_date.day, 
                                  h, 0 , 0 
              ) .new_offset( Rational(0,24) ) 
  
    # return ( now  + d.days + h.hours + m.minutes + s.seconds   ) .new_offset( Rational(0,24) ) 
    return adjusted_date 
  end

  def make_date_mins(*args)
    now = DateTime.now  
  
    d = ( args[0] || 0 )
    h = (args[1]  || 0)  
    m = (args[2] || 0)  
    s = (args[3] || 0)  
  
  
    target_date = ( now  + d.days + h.hours + m.minutes + s.seconds   ) .new_offset( Rational(0,24) ) 
  
  
    # what is being adjusted 
    adjusted_date = DateTime.new( target_date.year, target_date.month, target_date.day, 
                                  target_date.hour, target_date.minute , target_date.second
              ) .new_offset( Rational(0,24) ) 
  
    return adjusted_date
  end
    
 
end

