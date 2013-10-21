class Api::GroupLoansController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = GroupLoan.includes(:group_loan_memberships).where{
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
      @objects = GroupLoan.includes(:group_loan_memberships).page(params[:page]).per(params[:limit]).order("id DESC")
      @total = GroupLoan.count 
    end
    
    
    # render :json => { :group_loans => @objects , :total => @total , :success => true }
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
    
    
    params[:group_loan][:started_at] =  parse_date( params[:group_loan][:started_at] )
    params[:group_loan][:disbursed_at] =  parse_date( params[:group_loan][:disbursed_at] )
    params[:group_loan][:closed_at] =  parse_date( params[:group_loan][:closed_at] )
    params[:group_loan][:compulsory_savings_withdrawn_at] =  parse_date( params[:group_loan][:compulsory_savings_withdrawn_at] )

    if params[:start].present?  
      @object.start(:started_at => params[:group_loan][:started_at] )
    elsif params[:disburse].present?
      @object.disburse_loan( :disbursed_at => params[:group_loan][:disbursed_at] )
    elsif params[:close].present?
      @object.close( :closed_at => params[:group_loan][:closed_at] )
    elsif params[:withdraw].present?
      @object.withdraw_compulsory_savings( :compulsory_savings_withdrawn_at => params[:group_loan][:compulsory_savings_withdrawn_at] )
    else
      @object.update_object(params[:group_loan])
    end
    
    # @object.update_object( params[:group_loan] )
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :group_loans => [
                            :id 							=>  	@object.id                  ,
                          	:name 			 										 =>   @object.name                                ,
                          	:number_of_meetings 						 =>   @object.number_of_meetings                  ,
                          	:number_of_collections					 =>   @object.number_of_collections               ,
                          	:total_members_count             =>   @object.total_members_count, 
                          	:is_started 										 =>   @object.is_started                          ,
                          	:started_at 										 =>   format_date_friendly(@object.started_at)    ,
                          	:is_loan_disbursed 							 =>   @object.is_loan_disbursed                   ,
                          	:disbursed_at 									 =>   format_date_friendly( @object.disbursed_at) ,
                          	:is_closed 											 =>   @object.is_closed                           ,
                          	:closed_at 											 =>   format_date_friendly( @object.closed_at )   ,
                          	:is_compulsory_savings_withdrawn =>   @object.is_compulsory_savings_withdrawn     ,
                          	:compulsory_savings_withdrawn_at =>   format_date_friendly( @object.compulsory_savings_withdrawn_at),                            # 
                          	                           # :start_fund                               => @object.start_fund,
                          	                           # :disbursed_group_loan_memberships_count   => @object.disbursed_group_loan_memberships_count,
                          	                           # :disbursed_fund                           => @object.disbursed_fund,
                          	                           # :active_group_loan_memberships_count      => @object.active_group_loan_memberships.count
                          ],
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
  
  def show
    @object = GroupLoan.find_by_id params[:id]
    render :json => { :success => true, 
                      :group_loans => [
                          :id 						                 =>  	@object.id                  ,
                        	:name 			 										 =>   @object.name                                ,
                        	:number_of_meetings 						 =>   @object.number_of_meetings                  ,
                        	:number_of_collections					 =>   @object.number_of_collections               ,
                        	:total_members_count             =>   @object.total_members_count, 
                        	:is_started 										 =>   @object.is_started                          ,
                        	:started_at 										 =>   format_date_friendly(@object.started_at)    ,
                        	:is_loan_disbursed 							 =>   @object.is_loan_disbursed                   ,
                        	:disbursed_at 									 =>   format_date_friendly( @object.disbursed_at) ,
                        	:is_closed 											 =>   @object.is_closed                           ,
                        	:closed_at 											 =>   format_date_friendly( @object.closed_at )   ,
                        	:is_compulsory_savings_withdrawn =>   @object.is_compulsory_savings_withdrawn     ,
                        	:compulsory_savings_withdrawn_at =>   format_date_friendly( @object.compulsory_savings_withdrawn_at),                          
                          :start_fund                               => @object.start_fund,
                          :disbursed_group_loan_memberships_count   => @object.disbursed_group_loan_memberships_count,
                          :disbursed_fund                           => @object.disbursed_fund,
                        	:active_group_loan_memberships_count		  => @object.active_group_loan_memberships.count,
                        	:non_disbursed_fund => @object.non_disbursed_fund
                        	
                        	
                        ] , 
                      :total => Member.count }
  end

  def destroy
    @object = GroupLoan.find(params[:id])
    @object.delete_object 

    if ( not @object.persisted?   )  
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
      @objects = GroupLoan.where{ (name =~ query)    
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = GroupLoan.where{ (name =~ query)    
                              }.count
    else
      @objects = GroupLoan.where{ (id.eq selected_id)   
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
   
      @total = GroupLoan.where{ (id.eq selected_id)   
                              }.count 
    end
    
    
    render :json => { :records => @objects , :total => @total, :success => true }
  end
end
