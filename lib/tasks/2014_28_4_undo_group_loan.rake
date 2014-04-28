
task :undo_group_loan => :environment do
  
  # Undo group loan weekly collection
  
  GroupLoan.where(:is_loan_disbursed => true).each do |disbursed_group_loan|
    disbursed_group_loan.group_loan_weekly_collections.order("id DESC").each do |group_loan_weekly_collection|
      puts "The weeklycollection: #{group_loan_weekly_collection.id}"
      group_loan_weekly_collection.unconfirm
      group_loan_weekly_collection.uncollect
      group_loan_weekly_collection.uncreate_things
      
      disbursed_group_loan.is_loan_disbursed = false
      disbursed_group_loan.disbursed_at = nil 
      disbursed_group_loan.save 
      
      disbursed_group_loan.is_started = false
      disbursed_group_loan.started_at = nil 
      disbursed_group_loan.save 
    end
    
    
    disbursed_group_loan.undisburse_group_loan
    disbursed_group_loan.cancel_start 
    
  end
  
  puts "StartedGroupLoan: #{GroupLoan.where(:is_started => true).count}"
  puts "Collected_GroupLoanWeeklyCollection: #{GroupLoanWeeklyCollection.where(:is_collected => true).count}"
  puts "DeceasedClearance: #{DeceasedClearance.count}"
  puts "PrematureClerance: #{GroupLoanPrematureClearancePayment.count}"
  puts "Uncollectible: #{GroupLoanWeeklyUncollectible.count}"
  puts "RunAwayReceivable: #{GroupLoanRunAwayReceivable.count}"
  puts "DeceasedMember: #{Member.where(:is_deceased => true).count}"
  puts "RunAwayMember: #{Member.where(:is_run_away => true).count}"
  
  
end

task :create_member_status_report => :environment do
  filename = "member_status.csv"

  CSV.open(filename, 'w') do |csv|
    
    Member.all.each do |member|
      csv << [member.id_number, member.name, member.total_membership_savings, member.total_locked_savings_account, member.total_savings_account]
    end
  end
  
end

task :create_glm_status_report => :environment do
  filename = "glm_status.csv"

  CSV.open(filename, 'w') do |csv|
    
    GroupLoanMembership.joins(:group_loan, :member).all.each do |glm|
      csv << [glm.id, glm.member.name, glm.group_loan.name, glm.total_compulsory_savings.to_s]
    end
  end
  
end