require 'csv'

class GroupLoansController < ApplicationController
  def download_pending
    @group_loans = GroupLoan.where(:is_started => true, :is_closed => false ) 
    
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
