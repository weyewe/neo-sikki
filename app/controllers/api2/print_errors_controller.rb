class Api2::PrintErrorsController < Api2::BaseReportApiController
  

  # def index 
    
  #   @parent = Member.find_by_id params[:member_id]

  #   query  = @parent.print_errors.order("id DESC")

  #   independent_savings_array = [
  #                             SAVINGS_STATUS[:savings_account],
  #                             SAVINGS_STATUS[:membership],
  #                             SAVINGS_STATUS[:locked] ] 

  #   query = query.where(:savings_status => independent_savings_array)

  #   @objects = query.page(params[:page]).per(params[:limit]).order("id DESC")
  #   @total = query.count 
  # end

  def create 
    params[:print_error][:user_id] =  current_user.id 

    params[:print_error][:saving_date] =  parse_date( params[:print_error][:saving_date] )
    
    @object = PrintError.create_object( params[:print_error] )
  
    
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :print_errors =>[{
                          
                          :id               =>    @object.id                  ,
                          :amount        =>    @object.amount           ,
                          :print_status      =>    @object.print_status       ,
                          :reason      =>    @object.reason       ,
                          :saving_date => format_datetime_friendly( @object.saving_date ) 
                          
                           
                        }],
                        :total => @parent.print_errors.count }  
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
    @object = PrintError.find(params[:id]) 
    
    params[:print_error][:saving_date] =  parse_date( params[:print_error][:saving_date] )
    

    @object.update_object( params[:print_error] ) 
      
    
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :print_errors =>[{
                          
                          :id               =>    @object.id                  ,
                          :amount        =>    @object.amount           ,
                          :print_status      =>    @object.print_status       ,
                          :reason      =>    @object.reason       ,
                          :saving_date => format_datetime_friendly( @object.saving_date ) 
                          
                           
                        }],
                        :total => PrintError.count  } 
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
    @object = PrintError.find(params[:id]) 
    @object.delete_object 

    if  not @object.persisted?   
      render :json => { :success => true, :total => PrintError.count }  
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



end

# data_required_by 
