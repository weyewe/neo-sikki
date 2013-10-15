class Api::GroupLoanMembershipsController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = GroupLoanMembership.where{
        (is_deleted.eq false) & 
        (
          (name =~  livesearch )
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = GroupLoanMembership.where{
        (is_deleted.eq false) & 
        (
          (name =~  livesearch )
        )
      }.count
      
      # calendar
      
    elsif params[:parent_id].present?
      @objects = GroupLoanMembership.joins(:group_loan_product, :member, :group_loan).
                  where(:group_loan_id => params[:parent_id]).
                  page(params[:page]).per(params[:limit]).order("id DESC")
      @total = GroupLoanMembership.where(:group_loan_id => params[:group_loan_id]).count 
    elsif
      @objects = []
      @total = 0 
    end
    
    # render :json => { :group_loan_memberships => @objects , :total => @total , :success => true }
  end
  

  def create
    @object = GroupLoanMembership.create_object( params[:group_loan_membership] )
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :group_loan_memberships => [@object] , 
                        :total => GroupLoanMembership.count }  
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
    @object = GroupLoanMembership.find(params[:id])
    
    @object.update_object( params[:group_loan_membership] )
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :group_loan_memberships => [@object],
                        :total => GroupLoanMembership.count  } 
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
    @object = GroupLoanMembership.find(params[:id])
    @object.delete_object 

    if ( not @object.persisted?  or @object.is_deleted ) and @object.errors.size == 0 
      render :json => { :success => true, :total => GroupLoanMembership.count }  
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
      @objects = GroupLoanMembership.where{ (name =~ query)   & 
                                (is_deleted.eq false )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = GroupLoanMembership.where{ (name =~ query)   & 
                                (is_deleted.eq false )
                              }.count
    else
      @objects = GroupLoanMembership.where{ (id.eq selected_id)  & 
                                (is_deleted.eq false )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
   
      @objects = GroupLoanMembership.where{ (id.eq selected_id)  & 
                                (is_deleted.eq false )
                              }.count 
    end
    
    
    render :json => { :records => @objects , :total => @total, :success => true }
  end
end
