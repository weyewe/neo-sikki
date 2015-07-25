class Api2::MembersController < Api2::BaseReportApiController
  

  def index 
    
    query = Member.where(:is_deceased => false , :is_run_away => false )
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"

      query = query.where{
      	( name =~ livesearch) | 
      	( id_number =~ livesearch) 
      }
       
    else 
      @objects = Member.includes(:group_loan_memberships => [:group_loan]).page(params[:page]).per(params[:limit]).order("id DESC")
      @total = Member.count 
    end

    @objects = query.page(params[:page]).per(params[:limit]).order("id DESC")
    @total = query.count 
     
  end


  def get_total_members
    render :json => { :success => true, 
                      :total => Member.count   }
  end

end

# data_required_by 
