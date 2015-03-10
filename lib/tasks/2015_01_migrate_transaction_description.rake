class TransactionDataConverter


=begin
Adm (S-489) Semprotan

a. What is S-489 -> S-489 stands for "S" & "489". "S" means its product is "Sejahtera" and its group no. is 489.
b. What is Semprotan -> Group's name
=end
  def self.update_loan_disbursement_description(transaction_data)

    group_loan = GroupLoan.find_by_id( transaction_data.transaction_source_id)

    group_no = group_loan.group_number
    group_name = group_loan.name 

    appendix = self.extract_appendix( group_loan )

    msg = "Adm (#{appendix}-#{group_no}) #{group_name}"
    transaction_data.description = msg
    transaction_data.save
  end

=begin
S-1 Sawah Baru Set.11

a. What is S-1 -> S-1 stands for "S" & "1". "S" means its product is "Sejahtera" and its group no. is 1.
b. What is Sawah Baru -> Group's name
c. What is 11? I think it is the 11th weekly collection?
=end
  def self.update_group_loan_weekly_collection_description( transaction_data  ) 
    glwc = GroupLoanWeeklyCollection.find_by_id( transaction_data.transaction_source_id)
    group_loan = glwc.group_loan
    collection_week_number = glwc.week_number

    group_name = group_loan.name 
    group_no = group_loan.group_number

    appendix = self.extract_appendix( group_loan )


    msg = "#{appendix}-#{group_no} #{group_name} Set.#{collection_week_number}"
    transaction_data.description = msg
    transaction_data.save
  end

  def self.update_loan_close_withdrawal_return_description( transaction_data ) 
    group_loan = GroupLoan.find_by_id( transaction_data.transaction_source_id)

    group_no = group_loan.group_number
    group_name = group_loan.name 

    appendix = self.extract_appendix( group_loan )

    msg = "Bagi tab.  (#{appendix}-#{group_no}) #{group_name}"
    transaction_data.description = msg
    transaction_data.save
  end

=begin
Ecah ( 3055 ) Ambil Tab Pribadi
Ecah ( 3055 ) Simpan Tab Pribadi
=end
  def self.update_voluntary_savings_account_description( transaction_data ) 
    savings_entry = SavingsEntry.find_by_id( transaction_data.transaction_source_id )
    member = savings_entry.member 

    return if member.nil? or savings_entry.nil? 

    msg = ""
    if savings_entry.direction == FUND_TRANSFER_DIRECTION[:incoming]
      msg = "#{member.name} (#{member.id_number})  Tambah Tab. Pribadi"
    elsif savings_entry.direction == FUND_TRANSFER_DIRECTION[:outgoing]
      msg = "#{member.name} (#{member.id_number})  Ambil Tab. Pribadi"
    end

    transaction_data.description = msg
    transaction_data.save
  end

  def self.update_locked_savings_account_description( transaction_data ) 
    savings_entry = SavingsEntry.find_by_id( transaction_data.transaction_source_id )
    member = savings_entry.member 

    return if member.nil? or savings_entry.nil? 

    msg = ""
    if savings_entry.direction == FUND_TRANSFER_DIRECTION[:incoming]
      msg = "#{member.name} (#{member.id_number})  Tambah TMD"
    elsif savings_entry.direction == FUND_TRANSFER_DIRECTION[:outgoing]
      msg = "#{member.name} (#{member.id_number})  Ambil TMD"
    end

    transaction_data.description = msg
    transaction_data.save
  end

=begin 
Emayanti (S-474), Pelunasan

S = group loan product
474 = group_no

Emayanti  = member's name 
=end
  def self.update_premature_clearance_description( transaction_data ) 
    group_loan_premature_clearance_payment = GroupLoanPrematureClearancePayment.find_by_id(transaction_data.transaction_source_id)
    group_loan = group_loan_premature_clearance_payment.group_loan
    member = group_loan_premature_clearance_payment.group_loan_membership.member 

    return if group_loan.nil? or member.nil? 
    
    group_no = group_loan.group_number
    group_name = group_loan.name 

    appendix = self.extract_appendix( group_loan )

    msg = "#{member.name} (#{appendix}-#{group_no}) Pelunasan"
    transaction_data.description = msg
    transaction_data.save
  end

  def self.extract_appendix( group_loan)
    first_group_loan_product_name = group_loan.group_loan_memberships.first.group_loan_product.name
    appendix  = "N/A"
    appendix = "NS" if first_group_loan_product_name =~ /^NS/i 
    appendix = "S" if first_group_loan_product_name =~ /^S/i 

    return appendix
  end

  def self.update_description( transaction_data ) 
    if transaction_data.code ==  TRANSACTION_DATA_CODE[:loan_disbursement]
      self.update_loan_disbursement_description( transaction_data ) 
    end

    if transaction_data.code ==  TRANSACTION_DATA_CODE[:group_loan_weekly_collection]
      self.update_group_loan_weekly_collection_description( transaction_data ) 
    end

    if transaction_data.code ==  TRANSACTION_DATA_CODE[:group_loan_close_withdrawal_return]
      self.update_loan_close_withdrawal_return_description( transaction_data ) 
    end

    if transaction_data.code ==  TRANSACTION_DATA_CODE[:savings_account]
      self.update_voluntary_savings_account_description( transaction_data ) 
    end

    if transaction_data.code ==  TRANSACTION_DATA_CODE[:locked_savings_account]
      self.update_locked_savings_account_description( transaction_data ) 
    end

    if transaction_data.code ==  TRANSACTION_DATA_CODE[:group_loan_premature_clearance_remaining_weeks_payment]
      self.update_premature_clearance_description( transaction_data ) 
    end

  end
end

task :convert_transaction_description => :environment do
  
  transaction_data_count =  TransactionActivity.where(
      :is_contra_transaction => false,
      :code => [
          TRANSACTION_DATA_CODE[:loan_disbursement],
          TRANSACTION_DATA_CODE[:group_loan_weekly_collection],
          TRANSACTION_DATA_CODE[:group_loan_close_withdrawal_return],
          TRANSACTION_DATA_CODE[:savings_account],
          TRANSACTION_DATA_CODE[:locked_savings_account],
          TRANSACTION_DATA_CODE[:group_loan_premature_clearance_remaining_weeks_payment],
      ]
    ).count
  total = transaction_data_count.length
  
  counter = 1 
  
  TransactionActivity.where(
      :is_contra_transaction => false,
      :code => [
          TRANSACTION_DATA_CODE[:loan_disbursement],
          TRANSACTION_DATA_CODE[:group_loan_weekly_collection],
          TRANSACTION_DATA_CODE[:group_loan_close_withdrawal_return],
          TRANSACTION_DATA_CODE[:savings_account],
          TRANSACTION_DATA_CODE[:locked_savings_account],
          TRANSACTION_DATA_CODE[:group_loan_premature_clearance_remaining_weeks_payment],
      ]
    ).find_each do |x|

    puts "transaction #{counter}/#{total}"
    
    AccountingService::Deceased.delay.create_bad_debt_allocation(
        x.group_loan_membership.group_loan, 
        x.member, 
        x.group_loan_membership, 
        x)
    
    counter += 1 
  end
end
