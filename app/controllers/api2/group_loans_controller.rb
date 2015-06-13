class Api2::GroupLoansController < Api2::BaseReportApiController




  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = GroupLoan.includes(:group_loan_weekly_collections).where{
        ( is_loan_disbursed.eq true ) & 
        ( is_closed.eq false ) & 
        (
          (name =~  livesearch ) | 
          (group_number =~ livesearch ) 
        )
        
      }.page(params[:page]).per(params[:limit]).order("group_loans.id DESC")
      
      @total = GroupLoan.where{ 
        ( is_loan_disbursed.eq true ) & 
        ( is_closed.eq false ) & 
        (
          (name =~  livesearch ) | 
          (group_number =~ livesearch ) 
        )
      }.count

    end
  end

end


