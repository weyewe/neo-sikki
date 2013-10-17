class Api::GroupLoanWeeklyCollectionsController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = GroupLoanWeeklyCollection.where{
        (
          (name =~  livesearch )
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = GroupLoanWeeklyCollection.where{ 
        (
          (name =~  livesearch )
        )
      }.count
      
      # calendar
      
    elsif params[:parent_id].present?
      @objects = GroupLoanWeeklyCollection. 
                  where(:group_loan_id => params[:parent_id]).
                  page(params[:page]).per(params[:limit]).order("id ASC")
      @total = GroupLoanWeeklyCollection.where(:group_loan_id => params[:parent_id]).count 
    elsif
      @objects = []
      @total = 0 
    end
    
    # render :json => { :group_loan_weekly_collections => @objects , :total => @total , :success => true }
  end
  

  def create
    @object = GroupLoanWeeklyCollection.create_object( params[:group_loan_weekly_collection] )
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :group_loan_weekly_collections => [@object] , 
                        :total => GroupLoanWeeklyCollection.count }  
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
    @object = GroupLoanWeeklyCollection.find(params[:id])
    
    @object.update_object( params[:group_loan_weekly_collection] )
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :group_loan_weekly_collections => [@object],
                        :total => GroupLoanWeeklyCollection.count  } 
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
    @object = GroupLoanWeeklyCollection.find(params[:id])
    @object.delete_object 

    if ( not @object.persisted?  or @object.is_deleted ) and @object.errors.size == 0 
      render :json => { :success => true, :total => GroupLoanWeeklyCollection.count }  
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
      @objects = GroupLoanWeeklyCollection.where(:group_loan_id => params[:parent_id]).
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = GroupLoanWeeklyCollection.where(:group_loan_id =>  params[:parent_id]) .count
    else
      @objects = GroupLoanWeeklyCollection.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id ASC")
   
      @objects = GroupLoanWeeklyCollection.where{ (id.eq selected_id)  
                              }.count 
    end
    
    
    # render :json => { :records => @objects , :total => @total, :success => true }
  end
end
