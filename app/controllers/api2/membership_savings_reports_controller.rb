class Api2::MembershipSavingsReportsController < Api2::BaseReportApiController
  
  def index

    client_starting_datetime   = params[:starting_datetime].to_datetime 
    client_ending_datetime = params[:ending_datetime].to_datetime 

    @objects = Member.includes(:savings_entries).where{
      ( savings_entries.savings_status == SAVINGS_STATUS[:membership] ) & 
      ( savings_entries.confirmed_at.lte client_ending_datetime ) & 
      ( savings_entries.confirmed_at.gte client_starting_datetime)

    }.page( params[:page]).limit( params[:limit]).order("id ASC")

    @total = Member.includes(:savings_entries).where{
      ( savings_entries.savings_status == SAVINGS_STATUS[:membership] ) & 
      ( savings_entries.confirmed_at.lte client_ending_datetime ) & 
      ( savings_entries.confirmed_at.gte client_starting_datetime)

    }.count

  end

end


