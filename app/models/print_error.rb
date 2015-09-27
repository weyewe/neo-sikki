class PrintError < ActiveRecord::Base

	def self.create_object( params ) 
		new_object = self.new 
		new_object.user_id = params[:user_id]

		new_object.saving_date = params[:saving_date]
		new_object.amount = BigDecimal( params[:amount] || '0') 
		new_object.print_status  = params[:print_status]
		new_object.reason = params[:reason]
		new_object.member_id = params[:member_id]

		new_object.save 

		return new_object 
 
	end

	def update_object( params ) 
		self.saving_date = params[:saving_date]
		self.amount = BigDecimal( params[:amount] || '0') 
		self.print_status = params[:print_status]
		self.reason = params[:reason]
		self.member_id = params[:member_id]
		self.save 

		return self 
	end


	def delete_object

		self.destroy 

	end
end
