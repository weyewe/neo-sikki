require 'rubygems'
require 'pg'
require 'active_record'
require 'csv'
# 
# class MigrateWeeklyCollection
# 
# 
# =begin
# Column:
# 1. savings_status
# 2. amount 
# 3. direction (in / out?)
# 4. Member
# =end
# 
#   def perform_weekly_voluntary_savings_posting( group_loan, gl_wc)
#     if gl_wc.group_loan_weekly_collection_voluntary_savings_entries.each do |glwc_vse|
# 
#       AccountingService::WeeklyCollectionVoluntarySavings.create_journal_posting(
#       group_loan,
#       gl_wc,
#       glwc_vse
#       )
# 
#     end
#   end
# 
#   
# 
#   def perform_premature_clearance_posting( group_loan, gl_wc)
#     gl_wc.group_loan_premature_clearance_payments.each do |x|
# 
#       # deposit payment
#       deposit_amount                                               = x.premature_clearance_deposit_amount
# 
#       if deposit_amount != BigDecimal("0")
#         member                                                     = x.group_loan_membership.member 
#         AccountingService::PrematureClearance.create_premature_clearance_deposit_posting(group_loan,
#         member, 
#         x,
#         deposit_amount)
#       end
# 
# 
# 
#       # remaining weeks payment 
#       glp                                                          = x.group_loan_membership.group_loan_product
#       total_principal                                              = glp.principal * x.total_unpaid_week
#       total_interest                                               = glp.interest * x.total_unpaid_week
#       total_compulsory_savings                                     = glp.interest * x.total_unpaid_week
# 
# 
#       member                                                       = x.group_loan_membership.member 
# 
#       AccountingService::PrematureClearance.create_premature_clearance_posting(
#       group_loan,
#       member, 
#       total_principal,
#       total_interest, 
#       total_compulsory_savings,
#       x
#       )
# 
# 
#     end
#   end
#   
#   def perform_weekly_payment_posting(group_loan, gl_wc)
#     uncollectible_glm_id_list = gl_wc.uncollectible_group_loan_membership_id_list
#     active_glm_id_list        = gl_wc.active_group_loan_memberships.map {|x| x.id }
#     run_away_glm_id_list      = group_loan.
#                                   group_loan_memberships.joins(:group_loan_run_away_receivable).
#                                   where{
#                                     (deactivation_case.eq  GROUP_LOAN_DEACTIVATION_CASE[:run_away] ) & 
#                                     (group_loan_run_away_receivable.payment_case.eq GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly])
#                                     }.map{|x| x.id }
#       
#       
#     active_glm_id_list   = active_glm_id_list - uncollectible_glm_id_list
#     run_away_glm_id_list = run_away_glm_id_list - uncollectible_glm_id_list
# 
# 
# 
#     total_main_cash          = BigDecimal("0")
#     total_interest_revenue   = BigDecimal("0")
#     total_principal          = BigDecimal("0")
#     total_compulsory_savings = BigDecimal("0")
#     
#     GroupLoanMembership.where(:id    =>  active_glm_id_list + run_away_glm_id_list ).
#     joins(:group_loan_product).each do |glm|
#       total_interest_revenue +=   glm.group_loan_product.interest 
#       total_principal +=         glm.group_loan_product.principal 
#       total_compulsory_savings += glm.group_loan_product.compulsory_savings
#     end
# 
#     AccountingService::WeeklyPayment.create_journal_posting(
#       group_loan,
#       gl_wc,
#       total_compulsory_savings ,
#       total_principal,
#       total_interest_revenue
#     )
#   end
# 
# 
#   def perform
# 
#     total = GroupLoan.where(
#     :is_loan_disbursed   => true 
#     ).count
#      
#     counter = 1 
#     
#     GroupLoan.where(
#     :is_loan_disbursed   => true 
#     ).find_each do |group_loan|
#       puts "group_loan #{counter}/ #{total}"
# 
#       group_loan.group_loan_weekly_collections.where(:is_collected => true, :is_confirmed => true ).each do |gl_wc|
# 
# 
#         # perform posting for group_loan_weekly_collection voluntary-savings_entries
#         self.delay.perform_weekly_voluntary_savings_posting( group_loan, gl_wc)
# 
#         # PERFORM POSTING FOR WEEKLY PAYMENT 
#         self.delay.perform_weekly_payment_posting(group_loan, gl_wc)
# 
# 
#         # PERFORM POSTING FOR PREMATURE CLEARANCE
#         self.delay.perform_premature_clearance_posting( group_loan, gl_wc)
# 
# 
#       end
# 
#       counter += 1 
#     end
# 
# 
# 
# 
#   end
# end


task :generate_weekly_collection_gl   => :environment do
 a =  MigrateWeeklyCollection.new 
 a.perform
 
end
