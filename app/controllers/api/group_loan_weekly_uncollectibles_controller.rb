class Api::GroupLoanWeeklyUncollectiblesController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = GroupLoanWeeklyUncollectible.where{
        (
          (name =~  livesearch )
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = GroupLoanWeeklyUncollectible.where{ 
        (
          (name =~  livesearch )
        )
      }.count
      
      # calendar
      
    elsif params[:parent_id].present?
      @objects = GroupLoanWeeklyUncollectible.joins(:group_loan_weekly_collection, :group_loan_membership).
                  where(:group_loan_id => params[:parent_id]).
                  page(params[:page]).per(params[:limit]).order("id ASC")
      @total = GroupLoanWeeklyUncollectible.where(:group_loan_id => params[:parent_id]).count 
    elsif
      @objects = []
      @total = 0 
    end
    
    # render :json => { :group_loan_weekly_uncollectibles => @objects , :total => @total , :success => true }
  end
  

  def create
    @object = GroupLoanWeeklyUncollectible.create_object( params[:group_loan_weekly_uncollectible] )
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :group_loan_weekly_uncollectibles => [@object] , 
                        :total => GroupLoanWeeklyUncollectible.count }  
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
    @object = GroupLoanWeeklyUncollectible.find(params[:id])
    
    @object.update_object( params[:group_loan_weekly_uncollectible] )
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :group_loan_weekly_uncollectibles => [@object],
                        :total => GroupLoanWeeklyUncollectible.count  } 
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
    @object = GroupLoanWeeklyUncollectible.find(params[:id])
    @object.delete_object 

    if ( not @object.persisted?  or @object.is_deleted ) and @object.errors.size == 0 
      render :json => { :success => true, :total => GroupLoanWeeklyUncollectible.count }  
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
      @objects = GroupLoanWeeklyUncollectible.where{ (week_number =~ query)    
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = GroupLoanWeeklyUncollectible.where{ (week_number =~ query)   
                              }.count
    else
      @objects = GroupLoanWeeklyUncollectible.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id ASC")
   
      @total = GroupLoanWeeklyUncollectible.where{ (id.eq selected_id)  
                              }.count 
    end
    
    
    # render :json => { :records => @objects , :total => @total, :success => true }
  end
end
