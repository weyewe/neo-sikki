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
      1-112 Kas Kecil
      1-114 BRI 
    1-120 Dana yang dibatasi penggunaannya
    1-130 Investasi jangka pendek
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

=end