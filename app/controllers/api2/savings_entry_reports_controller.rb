class Api2::SavingsEntryReportsController < Api2::BaseReportApiController
  
  def index

    client_starting_datetime   = params[:starting_datetime].to_datetime 
    client_ending_datetime = params[:ending_datetime].to_datetime 

    @objects = SavingsEntry.includes(:member).where(
      :savings_status => SAVINGS_STATUS[:membership] 
    ).where{
        (confirmed_at.not_eq nil) & 
        
        (confirmed_at.lte ending ) & 
        (confirmed_at.gt starting)

    }.page( params[:page]).limit( params[:limit]).order("confirmed_at ASC")


    @total = SavingsEntry.includes(:member).where(
      :savings_status => SAVINGS_STATUS[:membership] 
    ).where{
        (confirmed_at.not_eq nil) & 
        
        (confirmed_at.lte ending ) & 
        (confirmed_at.gt starting)

    }.count

  end

end



