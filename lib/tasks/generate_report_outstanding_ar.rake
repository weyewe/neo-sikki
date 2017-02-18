require 'rubygems'
require 'pg'
require 'active_record'
require 'csv'



task :generate_outstanding_ar_ap_2016 => :environment do
  the_end_of_2016 = DateTime.new(2016,9,5).end_of_year

  array = []

  GroupLoan.where(:is_loan_disbursed => true).where{
    ( disbursed_at.lt my{the_end_of_2016}) &
    (
      (is_closed.eq true ) &
      (closed_at.gt  my{the_end_of_2016})
    ) |
    (
      is_closed.eq false
    )
  }.find_each do |gl|
    total_paid_weeks = gl.group_loan_weekly_collections.where{confirmed_at.lte my{the_end_of_2016} }.count

    remaining_week = gl.loan_duration - total_paid_weeks


    gl.group_loan_memberships.find_each do |glm|
      row  = []
      row << glm.member.id_number
      row << glm.member.name
      row << glm.group_loan_product.actual_amount_to_be_disbursed.to_s
      row << ( glm.group_loan_product.principal * remaining_week ).to_s


      member  = glm.member

 #
 # SAVINGS_STATUS[:membership]
 #
 #  SAVINGS_STATUS[:locked]
 #
 #  SAVINGS_STATUS[:savings_account]

        # direction  = FUND_TRANSFER_DIRECTION[:incoming]
      total_locked_savings_account  = member.total_locked_savings_account       -
        member.savings_entries.where(
                            :is_confirmed => true,
                            :direction =>  FUND_TRANSFER_DIRECTION[:incoming],
                            :savings_status => SAVINGS_STATUS[:locked]
                            ).
                            where{ confirmed_at.gte my{the_end_of_2016}}.sum("amount")   +

        member.savings_entries.where(
                            :is_confirmed => true,
                            :direction =>  FUND_TRANSFER_DIRECTION[:outgoing],
                            :savings_status => SAVINGS_STATUS[:locked]
                            ).
                            where{ confirmed_at.gte my{the_end_of_2016}}.sum("amount")



      total_membership_savings = member.total_membership_savings -
        member.savings_entries.where(
                            :is_confirmed => true,
                            :direction =>  FUND_TRANSFER_DIRECTION[:incoming],
                            :savings_status => SAVINGS_STATUS[:membership]
                            ).
                            where{ confirmed_at.gte my{the_end_of_2016}}.sum("amount")   +

        member.savings_entries.where(
                            :is_confirmed => true,
                            :direction =>  FUND_TRANSFER_DIRECTION[:outgoing],
                            :savings_status => SAVINGS_STATUS[:membership]
                            ).
                            where{ confirmed_at.gte my{the_end_of_2016}}.sum("amount")


      total_savings_account = member.total_savings_account -
        member.savings_entries.where(
                            :is_confirmed => true,
                            :direction =>  FUND_TRANSFER_DIRECTION[:incoming],
                            :savings_status => SAVINGS_STATUS[:savings_account]
                            ).
                            where{ confirmed_at.gte my{the_end_of_2016}}.sum("amount")   +

        member.savings_entries.where(
                            :is_confirmed => true,
                            :direction =>  FUND_TRANSFER_DIRECTION[:outgoing],
                            :savings_status => SAVINGS_STATUS[:savings_account]
                            ).
                            where{ confirmed_at.gte my{the_end_of_2016}}.sum("amount")


      row << total_locked_savings_account.to_s
      row << total_membership_savings.to_s
      row << total_savings_account.to_s

      array << row

    end

  end


  puts "The result: #{array}"

end



task :generate_outstanding_compulsory_savings_2016 => :environment do
  the_end_of_2016 = DateTime.new(2016,9,5).end_of_year

  array = []

  GroupLoan.where(:is_loan_disbursed => true).where{
    ( disbursed_at.lt my{the_end_of_2016}) &
    (
      (is_closed.eq true ) &
      (closed_at.gt  my{the_end_of_2016})
    ) |
    (
      is_closed.eq false
    )
  }.find_each do |gl|
    total_paid_weeks = gl.group_loan_weekly_collections.where{confirmed_at.lte my{the_end_of_2016} }.count

    remaining_week = gl.loan_duration - total_paid_weeks


    gl.group_loan_memberships.find_each do |glm|
      row  = []
      row << glm.member.id_number
      row << gl.name
      row << gl.group_number
      row << glm.member.name
      row << ( glm.group_loan_product.principal * gl.number_of_collections ).to_i


      member  = glm.member

 #
 # SAVINGS_STATUS[:membership]
 #
 #  SAVINGS_STATUS[:locked]
 #
 #  SAVINGS_STATUS[:savings_account]

        # direction  = FUND_TRANSFER_DIRECTION[:incoming]

      total_compulsory_savings  =   member.savings_entries.where(
                            :is_confirmed => true,
                            :direction =>  FUND_TRANSFER_DIRECTION[:incoming],
                            :savings_status => SAVINGS_STATUS[:group_loan_compulsory_savings]
                            ).#
                            #where{ confirmed_at.lte my{the_end_of_2016}}.sum("amount")   +

        member.savings_entries.where(
                            :is_confirmed => true,
                            :direction =>  FUND_TRANSFER_DIRECTION[:outgoing],
                            :savings_status => SAVINGS_STATUS[:group_loan_compulsory_savings]
                            )#.
                            #where{ confirmed_at.lte my{the_end_of_2016}}.sum("amount")

      row << total_compulsory_savings.to_i

      row << glm.total_compulsory_savings
      array << row

    end

  end

  puts "array: #{array}"

  # file_location = Rails.root.to_s + "/tmp/outstanding_compulsory_savings_2016.csv"
  #
  # CSV.open(file_location, "w") do |csv|
  #
  #
  #   array.each do |row|
  #
  #     csv << row
  #   end
  #
  # end

end
