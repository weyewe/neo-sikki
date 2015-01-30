class Api::TransactionDatasController < Api::BaseApiController
  
  def index
     
     
     if params[:livesearch].present? 
       livesearch = "%#{params[:livesearch]}%"
       @objects = TransactionData.active_objects.where{
         (is_deleted.eq false ) & 
         (
           (description =~  livesearch ) | 
           ( code =~ livesearch)
         )

       }.page(params[:page]).per(params[:limit]).order("id DESC")

       @total = TransactionData.active_objects.where{
         (is_deleted.eq false ) & 
         (
           (description =~  livesearch ) | 
            ( code =~ livesearch)
         )
       }.count
 
     elsif params[:start_date].present?
       start_date =  parse_date( params[:start_date] )
       end_date =  parse_date( params[:end_date] )
       @objects = TransactionData.where{
          (is_confirmed.eq true ) & 
          (transaction_datetime.gte start_date) & 
          ( transaction_datetime.lt end_date )
         }.page(params[:page]).per(params[:limit]).order("transaction_datetime DESC")


       @total = TransactionData.where{
              (is_confirmed.eq true ) & 
              (transaction_datetime.gte start_date) & 
              ( transaction_datetime.lt end_date )
            }.count

     else
       @objects = TransactionData.active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
       @total = TransactionData.active_objects.count
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
      @objects = TransactionData.where{  (title =~ query)   & 
                                (is_deleted.eq false )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    else
      @objects = TransactionData.where{ (id.eq selected_id)  & 
                                (is_deleted.eq false )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    end
    
    
    render :json => { :records => @objects , :total => @objects.count, :success => true }
  end
end
