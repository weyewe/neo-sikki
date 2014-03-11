class GroupLoanWeeklyCollectionVoluntarySavingsEntry < ActiveRecord::Base
  belongs_to :group_loan_membership
  belongs_to :group_loan_weekly_collection
end
