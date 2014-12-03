require 'csv'

class GroupLoansController < ApplicationController
  def download_pending
    @group_loans = GroupLoan.joins(:group_loan_weekly_collections).where(:is_started => true, :is_closed => false ) 
    
    # CSV.open("data.csv", "wb") do |csv|
    #   csv << data_filtered.first.keys
    #   data_filtered.each do |hash|
    #     csv << hash.values
    #   end
    # end
    # 
    # 
    # send_data file, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment;data=#{csv_file}.csv"
    
    send_data @group_loans.to_csv
  end
end


=begin
Get all group loan weekly payments
  that should make payment this week, but hasn't made any. 
  
  GroupLoanWeeklyCollection.where(:is_collected => false)
  
  not collected yet. 
  supposed to be paid within this week 
  
=end