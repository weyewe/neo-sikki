class Api2::SchwabReportsController < Api2::BaseReportApiController
  


  def get_savings_data( the_member, savings_type, the_direction , end_date  ) 
    SavingsEntry.where{
      (member_id.eq the_member.id) & 
      (savings_status.eq savings_type) & 
      (direction.eq  the_direction  ) & 
      (confirmed_at.lte end_date )  & 
      ( is_confirmed.eq true )
    }
  end


  def get_total_savings( the_member, savings_type, end_date )
    total_compulsory_savings_incoming = get_savings_data(
        the_member,
        savings_type, 
        FUND_TRANSFER_DIRECTION[:incoming] , 
        end_date 
      ).sum("amount")
 

    total_compulsory_savings_outgoing = get_savings_data(
        the_member,
        savings_type, 
        FUND_TRANSFER_DIRECTION[:outgoing] , 
        end_date 
      ).sum("amount")



    return total_compulsory_savings_incoming - total_compulsory_savings_outgoing
  end

  def index

 
 # puts  Member.page( 1 ).per( 100 ).order("id ASC").map{|x| x.id }

 
    october_2014  = DateTime.new(2014,10,4,0,0,0).utc.end_of_month 
    december_2014 = DateTime.new(2014,12,4,0,0,0).utc.end_of_month 
    may_2015  = DateTime.new(2015,5,4,0,0,0).utc.end_of_month 

    member_list = Member.page( params[:page]).per( params[:limit]) 
    @objects = [] 

    map = member_list.map{ |x| x.id } 
    puts map 

    member_list.each do |the_member|
      row = {}
      row['member_id']  = the_member.id_number
      row['member_name']  = the_member.name 
      first_glm = the_member.group_loan_memberships.order("id ASC").first 

      first_loan_disbursement_date = "N/A"
      if not first_glm.nil?  
        first_loan_disbursement_date = first_glm.group_loan.disbursed_at
      end
      
      row['first_loan_disbursement_date'] = first_loan_disbursement_date
 
      row['compulsory_savings_amount_by_oct_2014'] =  get_total_savings( 
        the_member, 
        SAVINGS_STATUS[:group_loan_compulsory_savings],
        october_2014)

      row['compulsory_savings_amount_by_dec_2014'] = get_total_savings( 
        the_member, 
        SAVINGS_STATUS[:group_loan_compulsory_savings],
        december_2014 )

      row['compulsory_savings_amount_by_may_2015'] = get_total_savings( 
        the_member, 
        SAVINGS_STATUS[:group_loan_compulsory_savings],
        may_2015 )

      row['voluntary_savings_amount_by_oct_2014'] = get_total_savings( 
        the_member, 
        SAVINGS_STATUS[:savings_account],
        october_2014 )
      row['voluntary_savings_amount_by_dec_2014'] = get_total_savings( 
        the_member, 
        SAVINGS_STATUS[:savings_account],
        december_2014 )

      row['voluntary_savings_amount_by_may_2015'] = get_total_savings( 
        the_member, 
        SAVINGS_STATUS[:savings_account],
        may_2015 )

=begin

    october_2014  = DateTime.new(2014,10,4,0,0,0).utc.end_of_month 
    december_2014 = DateTime.new(2014,12,4,0,0,0).utc.end_of_month 
    may_2015  = DateTime.new(2015,5,4,0,0,0).utc.end_of_month 


def ratio_in_month( target_datetime )
  start_datetime = target_datetime.beginning_of_month
  end_datetime = target_datetime.end_of_month 

  total_counter_weekly_collection = SavingsEntry.where{
            (is_confirmed.eq true )  &   
            (savings_source_type.eq  "GroupLoanWeeklyCollectionVoluntarySavingsEntry") & 
            ( confirmed_at.gte start_datetime ) & 
            ( confirmed_at.lt end_datetime )
          }.count 

  total_counter_independent = SavingsEntry.where{
            (savings_status.eq  SAVINGS_STATUS[:savings_account]) & 
            ( is_confirmed.eq true ) & 
            ( confirmed_at.gte start_datetime ) & 
            ( confirmed_at.lt end_datetime ) & 
            ( savings_source_type.eq nil )
          }.count 

  return [total_counter_weekly_collection , total_counter_independent]

end

array = [] 
(1.upto 12 ).each do |x|
  datetime  = DateTime.new(2013, x , 5, 0 ,0 ,0 ).utc 

  array <<   ratio_in_month( datetime ) 
end

array.each {|x| puts "#{x[0]}   : #{x[1]}" } 

SavingsEntry.where{
            (is_confirmed.eq true )  &   
            (savings_source_type.eq  "GroupLoanWeeklyCollectionVoluntarySavingsEntry") 
          }.order("confirmed_at ASC").first.confirmed_at 




 

start_jan_2015   = DateTime.new(2015,1,5,0,0,0).utc.beginning_of_month 
end_jan_2015   = DateTime.new(2015,1,5,0,0,0).utc.end_of_month


SavingsEntry.where{
  (is_confirmed.eq true )  &   
  (savings_source_type.eq  "GroupLoanWeeklyCollectionVoluntarySavingsEntry")  
}.count 

SavingsEntry.where{
  (is_confirmed.eq true )  &   
  (savings_source_type.eq  "GroupLoanWeeklyCollectionVoluntarySavingsEntry") & 
  ( confirmed_at.gte start_jan_2015 ) & 
  ( confirmed_at.lt end_jan_2105 )
}.count 


SavingsEntry.where{ 
  (savings_status.eq  SAVINGS_STATUS[:savings_account]) & 
  ( is_confirmed.eq true ) & 
  ( confirmed_at.gte start_jan_2015 ) & 
  ( confirmed_at.lt end_jan_2105 ) & 
  ( savings_source_type.eq nil )
}.count 
 
 
=end

      row['voluntary_savings_incoming_count_by_may_2015'] = get_savings_data( 
        the_member, 
        SAVINGS_STATUS[:savings_account], 
        FUND_TRANSFER_DIRECTION[:incoming] , 
        may_2015  ).count 

      row['voluntary_savings_outgoing_count_by_may_2015'] = get_savings_data( 
        the_member, 
        SAVINGS_STATUS[:savings_account], 
        FUND_TRANSFER_DIRECTION[:outgoing] , 
        may_2015  ).count 

      row['voluntary_savings_incoming_amount_by_may_2015'] = get_savings_data( 
        the_member, 
        SAVINGS_STATUS[:savings_account], 
        FUND_TRANSFER_DIRECTION[:incoming] , 
        may_2015  ).sum("amount") 

      row['voluntary_savings_outgoing_amount_by_may_2015'] = get_savings_data( 
        the_member, 
        SAVINGS_STATUS[:savings_account], 
        FUND_TRANSFER_DIRECTION[:outgoing] , 
        may_2015  ).sum("amount") 

      row['all_savings_amount_by_oct_2014'] = get_total_savings( 
        the_member, 
        SAVINGS_STATUS[:savings_account],
        october_2014 )  + 
      get_total_savings( 
        the_member, 
        SAVINGS_STATUS[:membership],
        october_2014 ) + 
      get_total_savings( 
        the_member, 
        SAVINGS_STATUS[:locked],
        october_2014 )

      row['all_savings_amount_by_dec_2014'] = get_total_savings( 
        the_member, 
        SAVINGS_STATUS[:savings_account],
        december_2014 )  + 
      get_total_savings( 
        the_member, 
        SAVINGS_STATUS[:membership],
        december_2014 ) + 
      get_total_savings( 
        the_member, 
        SAVINGS_STATUS[:locked],
        december_2014 )

      row['all_savings_amount_by_may_2015'] = get_total_savings( 
        the_member, 
        SAVINGS_STATUS[:savings_account],
        may_2015 )  + 
      get_total_savings( 
        the_member, 
        SAVINGS_STATUS[:membership],
        may_2015 ) + 
      get_total_savings( 
        the_member, 
        SAVINGS_STATUS[:locked],
        may_2015 )

      @objects << row 
    end


    @total = Member.count
    render :json => { :success => true, 
                  :records =>  @objects , 
                  :total => @total }  
  end

end



