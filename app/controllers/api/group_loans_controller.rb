class Api::GroupLoansController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = GroupLoan.where{
        (is_deleted.eq false) & 
        (
          (name =~  livesearch )
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = GroupLoan.where{
        (is_deleted.eq false) & 
        (
          (name =~  livesearch )
        )
      }.count
      
      # calendar
      
    else
      @objects = GroupLoan.page(params[:page]).per(params[:limit]).order("id DESC")
      @total = GroupLoan.count 
    end
    
    
    render :json => { :group_loans => @objects , :total => @total , :success => true }
  end

  def create
    # @object = GroupLoan.new(params[:group_loan])
 
    @object = GroupLoan.create_object( params[:group_loan] )
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :group_loans => [@object] , 
                        :total => GroupLoan.count }  
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
    @object = GroupLoan.find(params[:id])
    
    @object.update_object( params[:group_loan] )
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :group_loans => [@object],
                        :total => GroupLoan.count  } 
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
    @object = GroupLoan.find(params[:id])
    @object.delete_object 

    if ( not @object.persisted?  or @object.is_deleted ) and @object.errors.size == 0 
      render :json => { :success => true, :total => GroupLoan.count }  
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
      @objects = GroupLoan.where{ (name =~ query)   & 
                                (is_deleted.eq false )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = GroupLoan.where{ (name =~ query)   & 
                                (is_deleted.eq false )
                              }.count
    else
      @objects = GroupLoan.where{ (id.eq selected_id)  & 
                                (is_deleted.eq false )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
   
      @objects = GroupLoan.where{ (id.eq selected_id)  & 
                                (is_deleted.eq false )
                              }.count 
    end
    
    
    render :json => { :records => @objects , :total => @total, :success => true }
  end
end
