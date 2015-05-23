class Api2::GroupLoanWeeklyCollectionReportsController < Api2::BaseReportApiController
  
  def index

    @objects = GroupLoanWeeklyCollection. 
                page(params[:page]).per(params[:limit]).order("id ASC")

    @total = GroupLoanWeeklyCollection.count 

  
  end
  

  def show

  end

end

# data_required_by 
