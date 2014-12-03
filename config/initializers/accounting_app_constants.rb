GL_STATUS = {
  :credit => 1, 
  :debit => 2 
}


ACCOUNT_GROUP = {
  :asset => 1,
  :expense => 2, 
  :liability => 3, 
  :revenue => 4, 
  :equity => 5 
  
}


 
# level 0
ACCOUNT_CODE = {
  :asset => "1-000",
    :current_asset => "1-100",
      :cash_and_others => "1-110",
        :main_cash_leaf => "1-111",
    :account_receivable => "1-140",
      :pinjaman_sejahtera_ar_leaf => "1-141",
    :bad_debt_allocation => "1-150",
      :pinjaman_sejahtera_bda_leaf => "1-151",
      
      
  :liability => "2-000",
    :current_liability => "2-100",
      :savings => "2-110",
        :compulsory_savings_leaf => "2-111",
        :voluntary_savings_leaf => "2-112",
        :locked_savings_leaf => "2-113",
      :other_current_liability => "2-190",
        :utang_santunan_leaf => "2-191",
        :uang_titipan_leaf => "2-192",
        
  :equity => "3-000",
  
  
  :operating_revenue => "4-000",
    :loan_revenue => "4-100",
      :loan_administration_revenue => "4-110",
        :pinjaman_sejahtera_administration_revenue_leaf => "4-111",
      :interest_revenue => "4-120",
        :pinjaman_sejahtera_interest_revenue_leaf => "4-121",
        
  :financial_expense => "5-000",
  
  :operating_expense => "6-000" ,
    :account_receivable_allowance_expense => "6-200",
      :account_receivable_allowance_expense => "6-210",
        :pinjaman_sejahtera_arae_leaf => "6-211",
        
  :other_revenue => "7-000",
    :other_revenue_1 => "7-100",
      :other_revenue_2 => "7-110",
        :other_revenue_leaf => "7-118",
        
  :other_expense => "8-000",
  
  :coop_expense => "9-000",
}


# public class AccountCode
# {
#     public static string Asset = "1";
#     public static string CashBank = "11";
#     public static string AccountReceivable = "12";
#     public static string GBCHReceivable = "13";
#     public static string Inventory = "14";
#     public static string Expense = "2";
#     public static string COGS = "21";
#     public static string CashBankAdjustmentExpense = "22";
#     public static string Discount = "23";
#     public static string SalesAllowance = "24";
#     public static string StockAdjustmentExpense = "25";
#     public static string Liability = "3";
#     public static string AccountPayable = "31";
#     public static string GBCHPayable = "32";
#     public static string GoodsPendingClearance = "33";
#     public static string Equity = "4";
#     public static string OwnersEquity = "41";
#     public static string EquityAdjustment = "411";
#     public static string Revenue = "5";
# }
# 
# public class AccountLegacyCode
# {
#     public static string Asset = "A1";
#     public static string CashBank = "A11";
#     public static string AccountReceivable = "A12";
#     public static string GBCHReceivable = "A13";
#     public static string Inventory = "A14";
#     public static string Expense = "X1";
#     public static string COGS = "X11";
#     public static string CashBankAdjustmentExpense = "X12";
#     public static string Discount = "X13";
#     public static string SalesAllowance = "X14";
#     public static string StockAdjustmentExpense = "X15";
#     public static string Liability = "L1";
#     public static string AccountPayable = "L11";
#     public static string GBCHPayable = "L12";
#     public static string GoodsPendingClearance = "L13";
#     public static string Equity = "E1";
#     public static string OwnersEquity = "E11";
#     public static string EquityAdjustment = "E111";
#     public static string Revenue = "R1";
# 
#     public static string Unknown = "U1";
# }

=begin
Automated journaling

Debit side 
1-000 Aktiva
  1-100 Aktiva lancar 
    1-110 Kas dan setara kas
      1-111 Kas besar
      1-114 BRI    # menerima premi asuransi 
    1-140 Piutang 
      1-141 Piutang Pinjaman Sejahtera
    1-150 Penyisihan Piutang Tak Tertagih
      1-151 Penyisihan Piutang Tak Tertagih Pinjaman Sejahtera
      
      
2-000 Kewajiban
  2-100 Kewajiban Lancar
    2-110 Tabungan
      2-111 Tabungan Wajib
      2-112 Tabungan Pribadi
      2-113 Tabungan Masa Depan
    2-190 Utang Lancar Lainnya
      2-191 Utang Santunan
      2-192 Uang Titipan 
      
6-000 Beban Usaha
  6-200 Beban Penghapusan Piutang
    6-210 Beban Penghapusan Piutang
      6-211 Beban Penghapusan Piutang Pinjaman Sejahtera

      
    
4-000 Pendapatan Usaha
    4-100 Pendapatan Pinjaman
      4-110 Pendapatan Administrasi Pinjaman
        4-111 Pendapatan administrasi pinjaman sejahtera
        
      4-120 Pendapatan bagi hasil pinjaman
        4-121 Pendapatan bagi hasil pinjaman sejahtera
        
7-000 Pendapatan Lain-lain
  7-100 Pendapatan lain-lain
    7-110 Pendapatan lain-lain
      7-118 Pembulatan Nilai
      
        
      
1. 1-141 OK 
2. 1-111 OK 
3. 2-111 OK
4. 2-112 OK 
5. 2-113 OK 
6. 1-151 OK 
7. 6-211 OK 
8. 1-141 OK 
9. 1-114 OK 
10. 2-191 OK 
11. 2-192 OK 


Credit side
1. 1-111 OK 
2. 4-111 OK 
3. 1-141 OK 
4. 4-121 OK 
5. 2-111 OK 
6. 2-112 OK 
7. 2-113 OK 
8. 1-151 OK 
9. 2-191 OK 
10. 2-192 OK 
11. 7-118 OK 
12. 6-211 OK 



TRANSACTION LIST

1. Loan Disbursement
2. Weekly Payment
3. Savings Distribution  (compulsory savings part)
4. Voluntary Savings Withdrawal
5. Locked Savings Withdrawal
6. Voluntary Savings Addition
7. Locked Savings Addition
8. Member Run Away
  8.a. Jurnal pada saat  run away disetujui kantor pusat
  8.b. Jurnal penerimaan pembayaran cicilan pinjaman
  8.c. Jurnal di akhir periode: 
    8.c.1 Jurnal jika tabungan wajib cukup untuk principal + bunga
    8.c.1 Jurnal jika tabungan wajib hanya cukup untuk principal
    8.c.3 Jurnal jika tabungan wajib tidak cukup untuk principal
9.Deceased Member
    9.a. Jurnal di pembayaran cicilan mingguan 
    9.b. Jurnal ketika premi diterima 
10. Premature Clearance: jika tidak ada member run away sebelumnya
  10.a. jurnal pada saat permintaan pelunasan premature clearance
        Penerimaan pembayaran per normal di minggu tersebut 
        Permintaan pelunasan di minggu N, untuk minggu N+1 sampai akhir 
  10.b. jurnal pada saat penerimaan pembayaran pelunasan premature clearance
        Pembayaran sisa dari minggu N+1 sampai minggu terakhir   [principal + interest + compulsory savings]
  10.c. jurnal di minggu berikutnya , tanpa orang tersebut 
        
11. Premature Clearance: jika ada member run away sebelumnya (ada outstanding default), paid @the end of term
  11.a. Setoran dilakukan per normal, tidak termasuk tanggung renteng karena dilakukan terakhir 
  11.b. Melunasi sisa pokok pinjaman + bagiannya untuk principal + bunga dari nasabah yg kabur [ tidak perlu membayar interest + compulsory savings]

12. Premature Clearance: member run away paid weekly
13. 


How to create posting?

GeneralLedger.create_posting(
  Account.find_by_code( ACCOUNT_CODE[:main_cash], source_document, GL_STATUS[:credit], amount )
  Account.find_by_code( ACCOUNT_CODE[:main_cash], source_document, GL_STATUS[:debit], amount )
)
=end