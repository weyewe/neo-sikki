class Api::CollectionGroupsController < Api::BaseApiController
  
  def index
    

    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      
      
      @objects = CollectionGroup.joins(:branch, :user).where{
        (
          (name =~  livesearch ) | 
          (description =~ livesearch) | 
          (branch.name =~ livesearch) | 
          (user.name =~ livesearch) 
        )

      }.page(params[:page]).per(params[:limit]).order("id DESC")

      @total = CollectionGroup.joins(:branch, :user).where{
        (
          (name =~  livesearch ) | 
          (description =~ livesearch) | 
          (branch.name =~ livesearch) | 
          (user.name =~ livesearch) 
        )
      }.count
 
    else 
      @objects = CollectionGroup.joins(:branch, :user).order("id DESC").
                  page(params[:page]).per(params[:limit])
      @total = CollectionGroup.count 
    end
    
    

  end
  

  def create
    @object = CollectionGroup.create_object( params[:collection_group] )
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :collection_groups => [@object] , 
                        :total => CollectionGroup.count }  
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
    @object = CollectionGroup.find(params[:id])
    
    
    if params[:deactivate].present?  
      @object.deactivate(:deactivation_case => params[:group_loan_membership][:deactivation_case] )
    else
      @object.update_object( params[:collection_group] )
    end
    
    
    
    if @object.errors.size == 0 
        if params[:parent_id].present? 
            
            render :json => { :success => true,   
                            :collection_groups => [@object],
                            :total => CollectionGroup.where(:branch_id => params[:parent_id]).count  } 
        else 

            render :json => { :success => true,   
                            :collection_groups => [@object],
                            :total => CollectionGroup.count  } 
            
        end

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

#   def destroy
#     @object = GroupLoanMembership.find(params[:id])
#     @object.delete_object 

#     if  not @object.persisted? 
#       render :json => { :success => true, :total => GroupLoanMembership.count }  
#     else
#       msg = {
#         :success => false, 
#         :message => {
#           :errors => extjs_error_format( @object.errors )  
#         }
#       }
      
#       render :json => msg
#     end
#   end
  
  
  def search
    search_params = params[:query]
    selected_id = params[:selected_id]
    if params[:selected_id].nil?  or params[:selected_id].length == 0 
      selected_id = nil
    end
    
    query = "%#{search_params}%"
    # on PostGre SQL, it is ignoring lower case or upper case 
    parent_id = params[:parent_id]
    
    if  selected_id.nil?
        
        if params[:parent_id].present?

            @objects = CollectionGroup.where(:branch_id => params[:parent_id]).where{
                                    (name =~ query)  
                                }.
                                page(params[:page]).
                                per(params[:limit]).
                                order("id DESC")
                                
            @total = CollectionGroup.where(:branch_id => params[:parent_id]).where{
                                    (name =~ query)  
                                }.count
                                  
        else 

            @objects = CollectionGroup.where{
                                    (name =~ query)  
                                }.
                                page(params[:page]).
                                per(params[:limit]).
                                order("id DESC")
                            
            @total = GroupLoanMembership.where{
                                    (name =~ query)  
                                }.count
                                  
        end

    else
      @objects = CollectionGroup.where(:id => selected_id).
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
   
      @total = CollectionGroup.where(:id => selected_id)..count 
    end
    
    
  end
end
