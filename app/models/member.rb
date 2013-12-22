class Member < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :office 
  
  has_many :group_loans, :through => :group_loan_memberships 
  has_many :group_loan_memberships 
  
  has_many :savings_entries 
  # has_many :savings_account_payments 
  
  # has_many :group_loan_port_compulsory_savings 
  
  has_many :deceased_clearances
  
  # validates_uniqueness_of :id_number 
  validates_presence_of :name # , :id_number 
  
   
  def self.active_objects
    self.where(:is_deceased => false).order("id DESC")
  end
  
  def self.create_object(params)
    new_object           = self.new
    new_object.name      = params[:name]
    new_object.address   = params[:address]
    new_object.id_number = params[:id_number] 
    # next modification
    new_object.id_card_number = params[:id_card_number]  # KTP 
    new_object.birthday_date = params[:birthday_date]
    new_object.is_data_complete = params[:is_data_complete]

    new_object.save
    
    return new_object 
  end
  
  def update_object(params)
    self.name      = params[:name]
    self.address   = params[:address]
    self.id_number = params[:id_number]
    # next modification
    self.id_card_number = params[:id_card_number]
    self.birthday_date = params[:birthday_date]
    self.is_data_complete = params[:is_data_complete]

    self.save 
    if self.errors.size != 0 
      puts "************** AWESOMe"
      self.errors.messages.each do |msg|
        puts "The message: #{msg}"
      end
    end
  end
  
  def delete_object
    if self.group_loan_memberships.count != 0
      self.errors.add(:generic_errors, "Tidak bisa dihapus. Sudah ada pendaftaran produk")
      return self 
    end
    
    self.destroy 
  end
  
=begin
  Savings Related 
=end
  def update_total_savings_account(amount) 
    self.total_savings_account  +=  amount 
    self.save
  end
  
  def update_total_membership_savings_account(amount) 
    self.total_membership_savings  +=  amount 
    self.save
  end
  
  def update_total_locked_savings_account(amount) 
    self.total_locked_savings_account  +=  amount 
    self.save
  end
  
=begin
  Deceased member
=end

  def is_active?
    not self.is_deceased and not self.is_run_away
  end

  def mark_as_deceased( params ) 
    if self.is_deceased? 
      self.errors.add(:generic_errors, "#{self.name} sudah dinyatakan meninggal")
      return self 
    end
    
    
    if params[:deceased_at].nil? or not params[:deceased_at].is_a?(DateTime)
      self.errors.add(:deceased_at, "Harus ada tanggal meninggal")
      return self 
    end
    
    
    self.is_deceased = true 
    self.deceased_at = params[:deceased_at]
  
    if self.save  
      
      # loop across all financial products : for now , it is only group loan
      
      self.group_loan_memberships.where(:is_active => true ).each do |glm|
        # deactivate group loan membership
        glm.is_active = false 
        glm.deactivation_case = GROUP_LOAN_DEACTIVATION_CASE[:deceased]   
        
        group_loan = glm.group_loan 
        
        if group_loan.is_loan_disbursed? 
          glm.deactivation_week_number = group_loan.first_uncollected_weekly_collection.week_number
          glm.save  
          # puts "THe deactivation week number: #{glm.deactivation_week_number}"
          # bad_debt_allowance =   
          
          # group_loan.update_default_payment_amount_receivable
          
          description = "Deceased Clearance for group loan: #{glm.group_loan.name}" + 
              " for member: #{glm.member.name}, #{glm.member.id_number}"
          new_object = DeceasedClearance.create(
            :financial_product_id  => glm.group_loan.id,
            :financial_product_type => glm.group_loan.class.to_s, 
            :principal_return => glm.remaining_deceased_principal_payment,
            :member_id => glm.member_id, 
            :description => description,
            :additional_savings_account => glm.total_compulsory_savings 
          )
          
          if glm.total_compulsory_savings > BigDecimal('0')
            SavingsEntry.create_group_loan_compulsory_savings_withdrawal( new_object , glm.total_compulsory_savings )  
            SavingsEntry.create_savings_account_group_loan_deceased_addition( new_object , new_object.additional_savings_account)  
          end
                                  
        else
          glm.destroy
        end                                 
      end
      
    end
  end
  
  def mark_as_run_away(params)
    if self.is_run_away? 
      self.errors.add(:generic_errors, "#{self.name} sudah dinyatakan kabur")
      return self 
    end
    
    
    if params[:run_away_at].nil? or not params[:run_away_at].is_a?(DateTime)
      self.errors.add(:run_away_at, "Harus ada tanggal kabur")
      return self 
    end
    
    
    self.is_run_away = true  
    self.run_away_at = params[:run_away_at]
    
    if self.save 
      pending_receivable = BigDecimal('0')
      
      self.group_loan_memberships.where(:is_active => true ).each do |glm|
        # deactivate group loan membership
        glm.is_active = false 
        glm.deactivation_case = GROUP_LOAN_DEACTIVATION_CASE[:run_away]   
        
        group_loan = glm.group_loan 
        
        if group_loan.is_loan_disbursed? 
          glm.deactivation_week_number = group_loan.first_uncollected_weekly_collection.week_number
          glm.save  

          GroupLoanRunAwayReceivable.create :member_id => self.id,  
                                  :amount_receivable => glm.run_away_remaining_group_loan_payment ,
                                  :group_loan_weekly_collection_id => group_loan.first_uncollected_weekly_collection.id, 
                                  :group_loan_id => glm.group_loan_id,
                                  :group_loan_membership_id => glm.id , 
                                  :payment_case => GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly] # on end_of_cycle
        else
          glm.destroy
        end                                 
      end
       
    end
  end
end
