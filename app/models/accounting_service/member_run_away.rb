module AccountingService
  class MemberRunAway
    def MemberRunAway.create_bad_debt_allocation(group_loan, member, group_loan_membership, group_loan_weekly_collection,group_loan_run_away_receivable) 
      
      remaining_weeks = group_loan.number_of_collections - group_loan_weekly_collection.week_number + 1 
      remaining_principal = group_loan_membership.group_loan_product.principal * remaining_weeks 



      message = "Runaway Bad Debt Allowance: Group #{group_loan.name}, #{group_loan.group_number}, member: #{member.name}"

      ta = TransactionData.create_object({
        :transaction_datetime => group_loan_run_away_receivable.member.run_away_at,
        :description =>  message,
        :transaction_source_id => group_loan_run_away_receivable.id , 
        :transaction_source_type => group_loan_run_away_receivable.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_run_away_declaration],
        :is_contra_transaction => false 
      }, true )



      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_arae_leaf][:code]).id      ,
        :entry_case          => NORMAL_BALANCE[:debit]     ,
        :amount              => remaining_principal,
        :description => message
      )

      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_ar_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:credit]     ,
        :amount              => remaining_principal,
        :description => message
      )
      ta.confirm
    end
    
    def MemberRunAway.cancel_bad_debt_allocation(object)
    end

  end
end
