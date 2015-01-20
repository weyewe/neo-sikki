corner cases

puts " The uncollectible: #{ GroupLoanWeeklyUncollectible.count }" 
puts "The run away: #{GroupLoanRunAwayReceivable.count } " 
puts "The deceased: #{DeceasedClearance.count}" 
puts "THe premature clearance: #{GroupLoanPrematureClearancePayment.count}"

deceased_array = []
DeceasedClearance.all.each do |x|
	deceased_array << x.member 
	
end

deceased_array.each {|x| puts "The deceased_clearance_member: #{x.name}, #{x.id_number}"}

premature_clearance_group_loan_id_list = []

GroupLoanPrematureClearancePayment.all.each do |x|
	premature_clearance_group_loan_id_list << x.group_loan_id
end

deceased_clearance_group_loan_id_list = [] 

DeceasedClearance.all.each do |x|
	deceased_clearance_group_loan_id_list << x.financial_product_id
end

premature_clearance_group_loan_id_list.uniq! 
deceased_clearance_group_loan_id_list.uniq! 


awesome_id_list = []
premature_clearance_group_loan_id_list.each do |x| 
  awesome_id_list << x if deceased_clearance_group_loan_id_list.include?(x)
end

