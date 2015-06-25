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

a = Member.find_by_id_number("6619")
a.savings_entries.where{
    (savings_status.eq SAVINGS_STATUS[:savings_account]) & 
    (is_confirmed.eq true ) & 
    (confirmed_at.lte may_2015)

}.count 

a.savings_entries.where{
    (savings_status.eq SAVINGS_STATUS[:savings_account]) & 
    (is_confirmed.eq true ) & 
    (confirmed_at.gte may_2015)

}.count 

se = a.savings_entries.where{
    (savings_status.eq SAVINGS_STATUS[:savings_account]) & 
    (is_confirmed.eq true )  
}.count 

se = a.savings_entries.where{
    (savings_status.eq SAVINGS_STATUS[:savings_account]) & 
    (is_confirmed.eq true )   & 
    (confirmed_at.eq nil )
}.first 

se = a.savings_entries.where{
    (savings_status.eq SAVINGS_STATUS[:savings_account]) & 
    (is_confirmed.eq true ) & 
    (confirmed_at.lte may_2015) 
}.first 

SavingsEntry.where{
  (is_confirmed.eq true )  & 
  (confirmed_at.eq nil )  & 
  (savings_source_type.eq  "GroupLoanWeeklyCollectionVoluntarySavingsEntry")
}.count


counter = 0 
SavingsEntry.where{
  (is_confirmed.eq true )  & 
  (confirmed_at.eq nil )  & 
  (savings_source_type.eq  "GroupLoanWeeklyCollectionVoluntarySavingsEntry")
}.find_each do |se|
  puts "counter: #{counter}"
  grlwc_vse = GroupLoanWeeklyCollectionVoluntarySavingsEntry.find_by_id( se.savings_source_id )

  glwc = GroupLoanWeeklyCollection.find_by_id( grlwc_vse.group_loan_weekly_collection_id )
  se.confirmed_at = glwc.confirmed_at 
  se.save 
end



 
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



