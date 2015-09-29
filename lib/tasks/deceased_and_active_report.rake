require 'rubygems'
require 'fog'


task :member_deceased_2015 => :environment do
  
  date_2015 = DateTime.new(2015,5,5,0,0,0)
  beginning_of_year = date_2015.beginning_of_year
  end_of_year = date_2015.end_of_year

  array = [] 

  Member.where{
    ( is_deceased.eq true) & 
    ( deceased_at.gte beginning_of_year) & 
    ( deceased_at.lt end_of_year)

  }.all.each do |deceased_member|
    array << [
      deceased_member.name,
      deceased_member.id_number, 
      deceased_member.id_card_number,
      deceased_member.birthday_date,
      deceased_member.deceased_at
    ]
  end

  array.each do |x|
    puts x.join(",")
  end
end


task :active_glm_now => :environment do
  
  date_2015 = DateTime.now
  

  array = []

  GroupLoanMembership.includes(:member, :group_loan, :group_loan_product).where{
    ( is_active.eq true )  
  }.find_each do |glm|
    member = glm.member
    group_loan = glm.group_loan 
    glp = glm.group_loan_product 

    array << [
      member.name,
      member.id_number, 
      member.id_card_number,
      member.birthday_date,
      group_loan.name , 
      group_loan.group_number,
      glp.principal
    ]
  end

  array.each do |x|
    puts x.join(",") 
  end
end



