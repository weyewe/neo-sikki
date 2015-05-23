class Api2::GroupLoanWeeklyCollectionReportsController < Api2::BaseReportApiController
  
  def index

    @objects = GroupLoanWeeklyCollection. 
                page(params[:page]).per(params[:limit]).order("id ASC")

    @total = GroupLoanWeeklyCollection.count 

  
  end
  

  def show
  	@object  = GroupLoanWeeklyCollection.find_by_id params[:id]
  	@objects =[]

  	@active_glm_list = @object.active_group_loan_memberships.joins(:group_loan_product).order("id ASC")
	@glwc_attendance_list  = @object.group_loan_weekly_collection_attendances
   	@glwc_voluntary_savings_list = @object.group_loan_weekly_collection_voluntary_savings_entries
  

  	@active_glm_list.each do |active_glm|

  	  member = active_glm.member 
      member_name = active_glm.member.name 
      glp = active_glm.group_loan_product
      glwc_attendance = @glwc_attendance_list.where(
          :group_loan_membership_id => active_glm.id 
        ).first

      glwc_voluntary_savings = @glwc_voluntary_savings_list.where(
          :group_loan_membership_id => active_glm.id 
        ).first

      withdrawal_amount = BigDecimal("0")
      addition_amount = BigDecimal("0")

      if not glwc_voluntary_savings.nil?
        if glwc_voluntary_savings.direction == FUND_TRANSFER_DIRECTION[:incoming]
          addition_amount = glwc_voluntary_savings.amount 
        else
          withdrawal_amount = glwc_voluntary_savings.amount 
        end
      end
      
      
      payment_status = "ya"
      attendance_status = "ya"
      payment_status = "no" if glwc_attendance.payment_status == false
      attendance_status = "no" if glwc_attendance.attendance_status == false 
      
      remaining_amount = ( @group_loan.number_of_collections - @object.week_number ) *
                        glp.weekly_payment_amount

      total_principal_adjusted =  ( ( glp.principal * glp.total_weeks ) /1000 ).to_s.gsub(".0",'')
      total_installment_adjusted = ( ( glp.weekly_payment_amount ) /1000 ).to_s.gsub(".0",'')
      savings_addition_adjusted = ( ( addition_amount) /1000 ).to_s.gsub(".0",'')
      savings_withdrawal_adjusted = ( ( withdrawal_amount) /1000 ).to_s.gsub(".0",'')
      remaining_savings_adjusted = ( ( member.total_savings_account) /1000 ).to_s.gsub(".0",'')
      remaining_amount_adjusted = ( ( remaining_amount) /1000 ).to_s.gsub(".0",'')

      total_dtr = GroupLoanWeeklyCollectionAttendance.where(
          :group_loan_membership_id => active_glm.id,
          :group_loan_weekly_collection_id => @glwc_id_list,
          :payment_status => false
        ).count 

      total_telat = GroupLoanWeeklyCollectionAttendance.where(
          :group_loan_membership_id => active_glm.id,
          :group_loan_weekly_collection_id => @glwc_id_list,
          :attendance_status => false
        ).count 


  		@objects << {
  			:member_name					 	=> "#{member.name}",
  			:member_id_number					=> "#{member.id_number}",
  			:total_principal_adjusted 			=> "#{ total_principal_adjusted }",
  			:total_installment_adjusted 		=> "#{ total_installment_adjusted }",
  			:payment_status 					=> "#{payment_status}", # bayar
  			:attendance_status 					=> "#{attendance_status}", #  tepat waktu
  			:savings_addition_adjusted 			=> "#{savings_addition_adjusted}", # menabung minggu lalu
  			:savings_withdrawal_adjusted 		=> "#{savings_withdrawal_adjusted}", # ambil tab minggu lalu
  			:remaining_savings_adjusted			=> "#{ remaining_savings_adjusted }" , # saldo sisa tabungan pribadi
  			:remaining_amount_adjusted			=> "#{remaining_amount_adjusted}",  # sisa pinjaman
  			:total_dtr							=> "#{total_dtr}", 
  			:total_telat						=>	"#{total_telat}"
  		}


  	end

  	render :json => { :success => true, 
                      :group_loan_weekly_collection_report_details => [@objects]  }
    return 
  end

end

# data_required_by 
