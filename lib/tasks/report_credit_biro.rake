
require 'rubygems' 
require 'csv' 


# ID Debitur	Nomor ID Nasabah	Yes
# Nama Debitur	Nama Lengkap	Yes
# No KTP/ NIK		Yes
# Tanggal Lahir		Yes
# Alamat Debitur		Yes but limited based on members' KTP
# Kelurahan		Yes
# No Akad Awal	Tanggal Pencairan Periode Pinjaman ini	Yes
# Tanggal Jatuh Tempo	Tanggal berakhirnya Periode pinjaman ini	NO - but we can replace with loan duration, and KBIJ will calculate
# Plafon	Jumlah pinjaman periode ini	Yes


task :create_credit_biro_result => :environment do

	file_location = "/var/www/sikki/credit_biro.csv"

	CSV.open(file_location, "w") do |csv|  

		GroupLoanMembership.joins(:member, :group_loan, :group_loan_product).where{
				( is_active.eq  true ) & 
				( group_loan.is_loan_disbursed.eq true ) 
			}.order("members.id ASC").find_each do |glm|

			member = glm.member 
			group_loan = glm.group_loan
			group_loan_product = glm.group_loan_product 

			birthday_date = "" 


			if member.birthday_date.present?
				member_birthday = member.birthday_date 

				birthday_date << "#{member_birthday.day}/#{member_birthday.month}/#{member_birthday.year}"
			end

 

			group_loan_disbursement_date = group_loan.disbursed_at

			disbursement_date =  "#{group_loan_disbursement_date.day}/#{group_loan_disbursement_date.month}/#{group_loan_disbursement_date.year}"
			

			csv << [  
				member.id_number, 
				member.name , 
				member.id_card_number,
				birthday_date,
				member.address,
				member.village,
				disbursement_date,
				group_loan_product.total_weeks,
				group_loan_product.actual_amount_to_be_disbursed  
			]
		end
 
	end
end