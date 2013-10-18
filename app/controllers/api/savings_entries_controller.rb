class Api::SavingsEntriesController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = SavingsEntry.where{
        (
          (name =~  livesearch )
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = SavingsEntry.where{ 
        (
          (name =~  livesearch )
        )
      }.count
      
      # calendar
      
    elsif params[:parent_id].present? and params[:is_savings_account].present?
      @objects = SavingsEntry.joins(:member).
                  where(
                    :member_id => params[:parent_id],
                    :savings_status => SAVINGS_STATUS[:savings_account]).
                  page(params[:page]).per(params[:limit]).order("id DESC")
      @total = SavingsEntry.where(            
                  :member_id => params[:parent_id],
                  :savings_status => SAVINGS_STATUS[:savings_account]).count 
    
    end
    
    # render :json => { :savings_entries => @objects , :total => @total , :success => true }
  end
  

  def create
    @object = SavingsEntry.create_object( params[:savings_entry] )
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :savings_entries => [@object] , 
                        :total => SavingsEntry.count }  
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
    @object = SavingsEntry.find(params[:id])
    
    @object.update_object( params[:savings_entry] )
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :savings_entries => [@object],
                        :total => SavingsEntry.count  } 
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
    @object = SavingsEntry.find(params[:id])
    @object.delete_object 

    if ( not @object.persisted?  or @object.is_deleted ) and @object.errors.size == 0 
      render :json => { :success => true, :total => SavingsEntry.count }  
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
      @objects = SavingsEntry.where{ (week_number =~ query)    
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = SavingsEntry.where{ (week_number =~ query)   
                              }.count
    else
      @objects = SavingsEntry.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id ASC")
   
      @total = SavingsEntry.where{ (id.eq selected_id)  
                              }.count 
    end
    
    
    # render :json => { :records => @objects , :total => @total, :success => true }
  end
end