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
    new_object.rt      = params[:rt     ]
    new_object.rw      = params[:rw     ]
    new_object.village = params[:village] 

    if new_object.save
      new_object.id_number = new_object.id_number.strip
      new_object.save 
    end
    
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
    self.rt      = params[:rt     ]
    self.rw      = params[:rw     ]
    self.village = params[:village]

    self.save 
    if self.errors.size != 0 
      puts "************** AWESOMe"
      self.errors.messages.each do |msg|
        puts "The message: #{msg}"
      end
    else
      self.id_number = self.id_number.strip
      self.save
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
  
  def undo_mark_as_deceased(weekly_collection)
    # deceased_week_number? 
    self.group_loan_memberships.where(
      :is_active => false, 
      :deactivation_case => GROUP_LOAN_DEACTIVATION_CASE[:deceased] ,
      :deactivation_week_number => weekly_collection.week_number  
    ).each do |glm|
      
      deceased_clearance = DeceasedClearance.where(
        :financial_product_id  => glm.group_loan.id,
        :financial_product_type => glm.group_loan.class.to_s,
        :member_id => glm.member_id
      ).first 
      
      if not deceased_clearance.nil?
        # SavingsEntry.create_group_loan_compulsory_savings_withdrawal( new_object , glm.total_compulsory_savings )  
        total_amount = BigDecimal("0")
        SavingsEntry.where(
          :savings_source_id => deceased_clearance.id,
          :savings_source_type => deceased_clearance.class.to_s, 
          :savings_status => SAVINGS_STATUS[:group_loan_compulsory_savings],
          :direction => FUND_TRANSFER_DIRECTION[:outgoing],
          :financial_product_id => savings_source.group_loan_id ,
          :financial_product_type => savings_source.group_loan.class.to_s,
          :member_id => member.id, 
        ).each do |x|
          total_amount += x.amount 
          x.destroy 
        end
        
        glm.update_total_compulsory_savings( total_amount )
        
        # SavingsEntry.create_savings_account_group_loan_deceased_addition( new_object , new_object.additional_savings_account)
        total_amount = BigDecimal("0")
        SavingsEntry.where(
          :savings_source_id => deceased_clearance.id,
          :savings_source_type => deceased_clearance.class.to_s, 
          :savings_status => SAVINGS_STATUS[:savings_account],
          :direction => FUND_TRANSFER_DIRECTION[:incoming],
          :financial_product_id =>  deceased_clearance.group_loan.id  ,
          :financial_product_type => deceased_clearance.group_loan.class.to_s ,
          :member_id => member.id
        ).each do |x|
          total_amount += x.amount 
          x.destroy 
        end
        member.update_total_savings_account( -1*total_amount)
      end 
      
      
      
      deceased_clearance.destroy 
      glm.is_active = true 
      glm.deactivation_case = nil 
      glm.deactivation_week_number = nil 
      glm.save
    end
    
    self.is_deceased = false 
    self.deceased_at = nil 
    self.save 
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

  def undo_mark_as_run_away(weekly_collection)
    self.group_loan_memberships.where(
      :is_active => false, 
      :deactivation_case => GROUP_LOAN_DEACTIVATION_CASE[:run_away] , 
      :deactivation_week_number => weekly_collection.week_number
    ).each do |run_away_glm|
      
      
      GroupLoanRunAwayReceivable.create(
        :member_id => self.id,  
        :group_loan_id => run_away_glm.group_loan_id,
        :group_loan_membership_id => run_away_glm.id
      ).each do |run_away_receivable|
        run_away_receivable.destroy 
      end
       
       
      
      
      
      run_away_glm.deactivation_week_number = nil 
      run_away_glm.is_active = true 
      run_away_glm.deactivation_case = nil 
      run_away_glm.save 
      
    end
    
    self.is_run_away = false  
    self.run_away_at = nil
    self.save 
  end

end
