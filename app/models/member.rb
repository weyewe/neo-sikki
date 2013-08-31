class Member < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :office 
  
  has_many :group_loans, :through => :group_loan_memberships 
  has_many :group_loan_memberships 
  
  has_many :savings_entries 
  has_many :savings_account_payments 
  
  has_many :group_loan_port_compulsory_savings 
  
  validates_uniqueness_of :id_number 
  validates_presence_of :name, :id_number  
  
  def self.create_object(params)
    new_object           = self.new
    new_object.name      = params[:name]
    new_object.address   = params[:address]
    new_object.id_number = params[:id_number]

    new_object.save
    
    return new_object 
  end
  
  def update_object(params)
    self.name      = params[:name]
    self.address   = params[:address]
    self.id_number = params[:id_number]

    self.save 
  end
  
=begin
  Savings Related 
=end
  def update_total_savings_account
    incoming = self.savings_entries.where(
      :savings_status => SAVINGS_STATUS[:savings_account],
      :direction => FUND_TRANSFER_DIRECTION[:incoming]
    ).sum("amount")   
    
    outgoing = self.savings_entries.where(
      :savings_status => SAVINGS_STATUS[:savings_account],
      :direction => FUND_TRANSFER_DIRECTION[:outgoing]
    ).sum("amount")
    
    self.total_savings_account  = incoming - outgoing 
    self.save
  end
  
=begin
  Deceased member
=end

  def mark_as_deceased( params ) 
    if self.is_deceased? 
      self.errors.add(:generic_errors, "#{self.name} sudah dinyatakan meninggal")
      return self 
    end
    
    self.is_deceased = true 
    self.death_datetime = params[:death_datetime]
  
    if self.save 
      
      # group loan
      pending_receivable = BigDecimal('0')
      
      self.group_loan_memberships.where(:is_active => true ).each do |glm|
        # deactivate group loan membership
        glm.is_active = false 
        glm.deactivation_case = GROUP_LOAN_DEACTIVATION_CASE[:deceased]   
        
        group_loan = glm.group_loan 
        
        if group_loan.is_loan_disbursed? 
          glm.deactivation_week_number = group_loan.first_uncollected_weekly_collection.week_number
          glm.save  
          # puts "THe deactivation week number: #{glm.deactivation_week_number}"
          pending_receivable += glm.remaining_deceased_principal_payment    
        else
          glm.destroy
        end                                 
      end
      
      # personal loan 
      
      # Create DeceasedPrincipalPendingPayment  ( from multiple group loans ) 
      DeceasedPrincipalReceivable.create :member_id => self.id,  
                                              :amount_receivable => pending_receivable
                                              
      # Write Off Interest Receivable 
    end
  end
end
