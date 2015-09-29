class Api2::MembersController < Api2::BaseReportApiController
  

=begin
   
  SavingsEntry.where(:savings_status => SAVINGS_STATUS[:savings_account]).first.member.id


    independent_savings_array = [
                              SAVINGS_STATUS[:savings_account],
                              SAVINGS_STATUS[:membership],
                              SAVINGS_STATUS[:locked] ] 


=end
  def index 
    
    query = Member.where(:is_deceased => false , :is_run_away => false )
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"

      query = query.where{
      	( name =~ livesearch) 
      }
       
    end

    @objects = query.page(params[:page]).per(params[:limit]).order("members.id_number ASC")
    @total = query.count 
     
  end


  def get_total_members
    render :json => { :success => true, 
                      :total => Member.count   }
  end


  def active_members
    starting_datetime   = params[:starting_datetime].to_datetime 
    ending_datetime = params[:ending_datetime].to_datetime  


    query = Member.where{
      ( is_deceased.eq true) & 
      ( deceased_at.gte starting_datetime) & 
      ( deceased_at.lt ending_datetime)

    }
     
    @objects = query.page(params[:page]).per(params[:limit]).order("members.id_number ASC")
    @total = query.count  
  end

  def deceased_members
    starting_datetime   = params[:starting_datetime].to_datetime 
    ending_datetime = params[:ending_datetime].to_datetime  


    query = GroupLoanMembership.includes(:member, :group_loan, :group_loan_product).where{
     ( is_active.eq true )  
    }
     
    @objects = query.page(params[:page]).per(params[:limit]).order("group_loan_memberships.member_id ASC")
    @total = query.count  
  end

end

# data_required_by 
