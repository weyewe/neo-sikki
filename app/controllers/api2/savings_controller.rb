class Api2::SavingsController < Api2::BaseReportApiController
  

  def index 
    
    @parent = Member.find_by_id params[:member_id]

    query  = @parent.savings_entries.order("id DESC")

    independent_savings_array = [
                              SAVINGS_STATUS[:savings_account],
                              SAVINGS_STATUS[:membership],
                              SAVINGS_STATUS[:locked] ] 

    query = query.where(:savings_status => independent_savings_array)

    @objects = query.page(params[:page]).per(params[:limit]).order("id DESC")
    @total = query.count 
  end

  def create
    @parent = Member.find_by_id params[:member_id]
    params[:savings_entry][:savings_status] = SAVINGS_STATUS[:savings_account]
    @object = SavingsEntry.create_object( params[:savings_entry] )

    direction_text = ""
    if @object.direction == FUND_TRANSFER_DIRECTION[:incoming] 
      direction_text    =   "Penambahan" 
    elsif @object.direction == FUND_TRANSFER_DIRECTION[:outgoing]
      direction_text    =   "Penarikan" 
    end
    
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :savings_entries =>[{
                          
                          :id               =>    @object.id                  ,
                          :member_id        =>    @object.member.id           ,
                          :member_name      =>    @object.member.name         ,
                          :member_id_number =>    @object.member.id_number    ,
                          :direction        =>    @object.direction           ,
                          :direction_text   =>    direction_text              ,
                          :amount       => @object.amount,
                          :is_confirmed => @object.is_confirmed,
                          :confirmed_at => format_datetime_friendly( @object.confirmed_at ) 
                          
                           
                        }],
                        :total => @parent.savings_entries.count }  
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
    @parent = Member.find_by_id params[:member_id]

    params[:savings_entry][:savings_status] = SAVINGS_STATUS[:savings_account]
    
    params[:savings_entry][:confirmed_at] =  parse_date( params[:savings_entry][:confirmed_at] )
    

    @object.update_object( params[:savings_entry] ) 
      
    
    
    direction_text = ""
    if @object.direction == FUND_TRANSFER_DIRECTION[:incoming] 
      direction_text    =   "Penambahan" 
    elsif @object.direction == FUND_TRANSFER_DIRECTION[:outgoing]
      direction_text    =   "Penarikan" 
    end
    
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :savings_entries =>[{
                          
                          :id               =>    @object.id                  ,
                          :member_id        =>    @object.member.id           ,
                          :member_name      =>    @object.member.name         ,
                          :member_id_number =>    @object.member.id_number    ,
                          :direction        =>    @object.direction           ,
                          :direction_text   =>    direction_text              ,
                          :amount       => @object.amount,
                          :is_confirmed => @object.is_confirmed,
                          :confirmed_at => format_datetime_friendly( @object.confirmed_at ) 
                          
                           
                        }],
                        :total => @parent.savings_entries.count  } 
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
    @parent = Member.find_by_id params[:member_id]
    @object.delete_object 

    if  not @object.persisted?   
      render :json => { :success => true, :total => @parent.savings_entries.count }  
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
