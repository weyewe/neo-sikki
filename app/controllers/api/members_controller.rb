class Api::MembersController < Api::BaseApiController
  
  def index
    
    is_deceased_value = false 
    is_run_away_value = false 
    
    is_deceased_value = true if params[:is_deceased].present?
    is_run_away_value = true if params[:is_run_away].present?
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = Member.where{
        (is_deceased.eq is_deceased_value) & 
        (is_run_away.eq is_run_away_value ) & 
        (
          (name =~  livesearch )
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = Member.where{
        (is_deceased.eq is_deceased_value) & 
        (is_run_away.eq is_run_away_value ) & 
        (
          (name =~  livesearch )
        )
      }.count
      
      # calendar
      
    elsif params[:is_deceased].present? 
      @objects = Member.where(:is_deceased => true ).page(params[:page]).per(params[:limit]).order("deceased_at DESC")
      @total = Member.where(:is_deceased => true ).count
    elsif params[:is_run_away].present? 
      @objects = Member.where(:is_run_away => true ).page(params[:page]).per(params[:limit]).order("run_away_at DESC")
      @total = Member.where(:is_run_away => true ).count
    else
      @objects = Member.active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
      @total = Member.active_objects.count 
    end
    
    
    render :json => { :members => @objects , :total => @total , :success => true }
  end

  def create
    # @object = Member.new(params[:member])
 
    @object = Member.create_object( params[:member] )
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :members => [@object] , 
                        :total => Member.active_objects.count }  
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
    @object = Member.find(params[:id])
    
    @object.update_object( params[:member] )
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :members => [@object],
                        :total => Member.active_objects.count  } 
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
  
  def show
    @object = Member.find_by_id params[:id]
    render :json => { :success => true, 
                      :members => [@object] , 
                      :total => Member.count }
  end

  def destroy
    @object = Member.find(params[:id])
    @object.delete_object 

    if ( not @object.persisted?  or @object.is_deleted ) and @object.errors.size == 0 
      render :json => { :success => true, :total => Member.active_objects.count }  
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
      @objects = Member.where{ (name =~ query)   
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = Member.where{ (name =~ query)  
                              }.count
    else
      @objects = Member.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
   
      @total = Member.where{ (id.eq selected_id)   
                              }.count 
    end
    
    
    render :json => { :records => @objects , :total => @total, :success => true }
  end
end
