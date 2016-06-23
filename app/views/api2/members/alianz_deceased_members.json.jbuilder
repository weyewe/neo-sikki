
json.success true
json.total @total
json.deceased_members @objects do |object|

    json.name                 object.member.name
    json.group_number         object.group_loan.group_number
    json.group_name           object.group_loan.name
    json.disbursement_amount  object.group_loan_product.principal.to_s
    json.deceased_date      "#{object.member.deceased_at.year}/#{object.member.deceased_at.month}/#{object.member.deceased_at.day}"
    json.completed_payment   ( ( object.deactivation_week_number - 1 ) * object.group_loan_product. weekly_payment_amount).to_s




end
