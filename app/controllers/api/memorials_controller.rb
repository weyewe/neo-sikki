class Api::MemorialsController < Api::BaseApiController
  
  def index
     
     
     @objects = Memorial.page(params[:page]).per(params[:limit]).order("id DESC")
     @total = Memorial.count
  end

  def create
    
    params[:memorial][:transaction_datetime] =  parse_date( params[:memorial][:transaction_datetime] )
    
    
    @object = Memorial.create_object( params[:memorial])
 
    if @object.errors.size == 0 
      
      render :json => { :success => true, 
                        :memorials => [
                          
                          :code => @object.code ,
                          :description => @object.description ,
                          :transaction_datetime => format_date_friendly(@object.transaction_datetime)  ,
                          :is_confirmed => @object.is_confirmed,
                          :confirmed_at => format_date_friendly(@object.confirmed_at) 
                          ] , 
                        :total => Memorial.active_objects.count }  
    else
      puts "It is fucking error!!\n"*10
      @object.errors.messages.each {|x| puts x }
      
      msg = {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors ) 
          # :errors => {
          #   :name => "Nama tidak boleh bombastic"
          # }
        }
      }
      
      render :json => msg                         
    end
  end
  
  def show
    @object  = Memorial.find params[:id]
    render :json => { :success => true,   
                      :memorial => @object,
                      :total => Memorial.active_objects.count  }
  end

  def update
    params[:memorial][:transaction_datetime] =  parse_date( params[:memorial][:transaction_datetime] )
    @object = Memorial.find(params[:id])
    
    # quick hack for ext-memorial 
    if not current_user.has_role?(:memorials , :update_details)
      # render :json => {:success => false, :access_denied => "Sudah Konfirmasi. Hanya dapat di hapus manager atau admin"}
      render :json => {:success => true, :message => "Good"}
      return 
    end
    
    
    @object.update_object(params[:memorial])
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :memorials => [
                          
                            :code => @object.code ,
                            :description => @object.description ,
                            :transaction_datetime => format_date_friendly(@object.transaction_datetime),
                            :is_confirmed => @object.is_confirmed,
                            :confirmed_at => format_date_friendly(@object.confirmed_at)
                          ],
                        :total => Memorial.active_objects.count  } 
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
  
  def confirm
    @object = Memorial.find_by_id params[:id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @object.confirm(params)
    
    if @object.errors.size == 0  and @object.is_confirmed? 
      render :json => { :success => true, :total => Booking.active_objects.count }  
    else
      # render :json => { :success => false, :total => Delivery.active_objects.count } 
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
    @object = Memorial.find(params[:id])
    @object.delete_object

    if (( not @object.persisted? )   or @object.is_deleted ) and @object.errors.size == 0
      render :json => { :success => true, :total => Memorial.active_objects.count }  
    else
      render :json => { :success => false, :total => Memorial.active_objects.count, 
        :message => {
          :errors => extjs_error_format( @object.errors )  
        } 
      }  
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
      @objects = Memorial.where{  (title =~ query)   & 
                                (is_deleted.eq false )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    else
      @objects = Memorial.where{ (id.eq selected_id)  & 
                                (is_deleted.eq false )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    end
    
    
    render :json => { :records => @objects , :total => @objects.count, :success => true }
  end
end
