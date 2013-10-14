class Api::GroupLoanProductsController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = GroupLoanProduct.where{
        (is_deleted.eq false) & 
        (
          (name =~  livesearch )
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = GroupLoanProduct.where{
        (is_deleted.eq false) & 
        (
          (name =~  livesearch )
        )
      }.count
      
      # calendar
      
    else
      @objects = GroupLoanProduct.page(params[:page]).per(params[:limit]).order("id DESC")
      @total = GroupLoanProduct.count 
    end
    
    
    render :json => { :group_loan_products => @objects , :total => @total , :success => true }
  end

  def create
    # @object = GroupLoanProduct.new(params[:group_loan_product])
 
    @object = GroupLoanProduct.create_object( params[:group_loan_product] )
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :group_loan_products => [@object] , 
                        :total => GroupLoanProduct.count }  
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
    @object = GroupLoanProduct.find(params[:id])
    
    @object.update_object( params[:group_loan_product] )
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :group_loan_products => [@object],
                        :total => GroupLoanProduct.count  } 
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
    @object = GroupLoanProduct.find(params[:id])
    @object.delete_object 

    if ( not @object.persisted?  or @object.is_deleted ) and @object.errors.size == 0 
      render :json => { :success => true, :total => GroupLoanProduct.count }  
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
      @objects = GroupLoanProduct.where{ (name =~ query)   & 
                                (is_deleted.eq false )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = GroupLoanProduct.where{ (name =~ query)   & 
                                (is_deleted.eq false )
                              }.count
    else
      @objects = GroupLoanProduct.where{ (id.eq selected_id)  & 
                                (is_deleted.eq false )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
   
      @objects = GroupLoanProduct.where{ (id.eq selected_id)  & 
                                (is_deleted.eq false )
                              }.count 
    end
    
    
    render :json => { :records => @objects , :total => @total, :success => true }
  end
end
