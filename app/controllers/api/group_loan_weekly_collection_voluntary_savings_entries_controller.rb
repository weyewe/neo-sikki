class Api::GroupLoanWeeklyCollectionVoluntarySavingsEntriesController < Api::BaseApiController
  # GroupLoanWeeklyCollectionVoluntarySavingsEntriesController


  def index

    # puts "This is awesome <==========\n"*10

    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = GroupLoanWeeklyCollectionVoluntarySavingsEntry.where{
        (
          (name =~  livesearch )
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = GroupLoanWeeklyCollectionVoluntarySavingsEntry.where{ 
        (
          (name =~  livesearch )
        )
      }.count
      
      # calendar
      
    elsif params[:parent_id].present?
      @objects = GroupLoanWeeklyCollectionVoluntarySavingsEntry. joins(:group_loan_membership => :member).
                  where(:group_loan_weekly_collection_id => params[:parent_id]).
                  page(params[:page]).per(params[:limit]).order("id ASC")
      @total = GroupLoanWeeklyCollectionVoluntarySavingsEntry.where(:group_loan_weekly_collection_id => params[:parent_id]).count 
    else
      @objects = []
      @total = 0 
    end

    # render :json => { :group_loan_weekly_collection_voluntary_savings_entry_voluntary_savings_entries => @objects , :total => @total , :success => true }
  end


  def create
    @object = GroupLoanWeeklyCollectionVoluntarySavingsEntry.create_object( params[:group_loan_weekly_collection_voluntary_savings_entry] )
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :group_loan_weekly_collection_voluntary_savings_entry_voluntary_savings_entries => [@object] , 
                        :total => GroupLoanWeeklyCollectionVoluntarySavingsEntry.count }  
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
    @object = GroupLoanWeeklyCollectionVoluntarySavingsEntry.find(params[:id])


    params[:group_loan_weekly_collection_voluntary_savings_entry][:collected_at] =  parse_date( params[:group_loan_weekly_collection_voluntary_savings_entry][:collected_at] ) 
    params[:group_loan_weekly_collection_voluntary_savings_entry][:confirmed_at] =  parse_date( params[:group_loan_weekly_collection_voluntary_savings_entry][:confirmed_at] ) 

    if params[:collect].present?  
      @object.collect(:collected_at => params[:group_loan_weekly_collection_voluntary_savings_entry][:collected_at] )
    elsif params[:confirm].present?
      @object.confirm( :confirmed_at => params[:group_loan_weekly_collection_voluntary_savings_entry][:confirmed_at] )
    else
      @object.update_object(params[:group_loan_weekly_collection_voluntary_savings_entry])
    end

    # @object.update_object( params[:group_loan] )
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :group_loan_weekly_collection_voluntary_savings_entry_voluntary_savings_entries => [
                            :id               =>    @object.id                  ,
                            :group_loan_id      =>     @object.group_loan_id   ,
                            :group_loan_name    =>    @object.group_loan.name  ,
                            :week_number        =>    @object.week_number      ,
                            :is_collected       =>    @object.is_collected     ,
                            :is_confirmed       =>    @object.is_confirmed     ,
                            :collected_at       =>    format_date_friendly( @object.collected_at )   ,
                            :confirmed_at       =>     format_date_friendly( @object.confirmed_at )  ,
                            :group_loan_weekly_uncollectible_count        => @object.group_loan_weekly_uncollectible_count,
                            :group_loan_deceased_clearance_count          => @object.group_loan_deceased_clearance_count  ,
                            :group_loan_run_away_receivable_count         => @object.group_loan_run_away_receivable_count ,
                            :group_loan_premature_clearance_payment_count => @object.group_loan_premature_clearance_payment_count,
                            :amount_receivable => @object.amount_receivable 

                          ],
                        :total => GroupLoanWeeklyCollectionVoluntarySavingsEntry.count  } 
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
    @object = GroupLoanWeeklyCollectionVoluntarySavingsEntry.find_by_id params[:id] 
    render :json => { :success => true, 
                      :group_loan_weekly_collection_voluntary_savings_entry_voluntary_savings_entries => [
                          :id               =>    @object.id                  ,
                          :group_loan_id      =>     @object.group_loan_id   ,
                          :group_loan_name    =>    @object.group_loan.name  ,
                          :week_number        =>    @object.week_number      ,
                          :is_collected       =>    @object.is_collected     ,
                          :is_confirmed       =>    @object.is_confirmed     ,
                          :collected_at       =>    format_date_friendly( @object.collected_at )   ,
                          :confirmed_at       =>     format_date_friendly( @object.confirmed_at )  ,
                          :group_loan_weekly_uncollectible_count        => @object.group_loan_weekly_uncollectible_count,
                          :group_loan_deceased_clearance_count          => @object.group_loan_deceased_clearance_count  ,
                          :group_loan_run_away_receivable_count         => @object.group_loan_run_away_receivable_count ,
                          :group_loan_premature_clearance_payment_count => @object.group_loan_premature_clearance_payment_count,
                          :amount_receivable => @object.amount_receivable


                        ] , 
                      :total => GroupLoanWeeklyCollectionVoluntarySavingsEntry.count }
  end

  def destroy
    # @object = GroupLoanWeeklyCollectionVoluntarySavingsEntry.find(params[:id])
    # @object.delete_object 
    # 
    # if ( not @object.persisted?  or @object.is_deleted ) and @object.errors.size == 0 
    #   render :json => { :success => true, :total => GroupLoanWeeklyCollectionVoluntarySavingsEntry.count }  
    # else
    #   msg = {
    #     :success => false, 
    #     :message => {
    #       :errors => extjs_error_format( @object.errors )  
    #     }
    #   }
    #   
    #   render :json => msg
    # end
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
      @objects = GroupLoanWeeklyCollectionVoluntarySavingsEntry.where(:group_loan_id => params[:parent_id]).
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")

      @total = GroupLoanWeeklyCollectionVoluntarySavingsEntry.where(:group_loan_id =>  params[:parent_id]) .count
    else
      @objects = GroupLoanWeeklyCollectionVoluntarySavingsEntry.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id ASC")

      @total = GroupLoanWeeklyCollectionVoluntarySavingsEntry.where{ (id.eq selected_id)  
                              }.count 
    end


    # render :json => { :records => @objects , :total => @total, :success => true }
  end
  
end

