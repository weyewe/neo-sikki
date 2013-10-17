class Api::GroupLoanRunAwayReceivablessController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = GroupLoanRunAwayReceivables.where{
        (
          (name =~  livesearch )
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = GroupLoanRunAwayReceivables.where{ 
        (
          (name =~  livesearch )
        )
      }.count
      
      # calendar
      
    elsif params[:parent_id].present?
      @objects = GroupLoanRunAwayReceivables.joins(:member, :group_loan_membership, :group_loan, :group_loan_weekly_collection).
                  where(:member_id => params[:parent_id]).
                  page(params[:page]).per(params[:limit]).order("id ASC")
      @total = GroupLoanRunAwayReceivables.where(:member_id => params[:parent_id]).count 
    elsif
      @objects = []
      @total = 0 
    end
    
    # render :json => { :group_loan_run_away_receivables => @objects , :total => @total , :success => true }
  end
  

  def create
    @object = GroupLoanRunAwayReceivables.create_object( params[:group_loan_run_away_receivable] )
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :group_loan_run_away_receivables => [@object] , 
                        :total => GroupLoanRunAwayReceivables.count }  
    else
      msg = {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors )  
        }
      }
      
      render :json => msg                         
    end
  end

  def update
    @object = GroupLoanRunAwayReceivables.find(params[:id])
    
    @object.update_object( params[:group_loan_run_away_receivable] )
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :group_loan_run_away_receivables => [@object],
                        :total => GroupLoanRunAwayReceivables.count  } 
    else
      msg = {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors )  
        }
      }
      
      render :json => msg
      
      
    end
  end

  def destroy
    @object = GroupLoanRunAwayReceivables.find(params[:id])
    @object.delete_object 

    if ( not @object.persisted?  or @object.is_deleted ) and @object.errors.size == 0 
      render :json => { :success => true, :total => GroupLoanRunAwayReceivables.count }  
    else
      msg = {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors )  
        }
      }
      
      render :json => msg
    end
  end
  
  
  def search
    search_params = params[:query]
    selected_id = params[:selected_id]
    if params[:selected_id].nil?  or params[:selected_id].length == 0 
      selected_id = nil
    end
    
    query = "%#{search_params}%"
    # on PostGre SQL, it is ignoring lower case or upper case 
    
    if  selected_id.nil?
      @objects = GroupLoanRunAwayReceivables.where{ (week_number =~ query)    
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = GroupLoanRunAwayReceivables.where{ (week_number =~ query)   
                              }.count
    else
      @objects = GroupLoanRunAwayReceivables.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id ASC")
   
      @total = GroupLoanRunAwayReceivables.where{ (id.eq selected_id)  
                              }.count 
    end
    
    
    # render :json => { :records => @objects , :total => @total, :success => true }
  end
end
