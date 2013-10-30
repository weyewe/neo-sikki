# this is the backbone to track savings, any kind of savings
# group_loan_compulsory_savings, group_loan_voluntary_savings 
# normal_savings_account (with interest monthly)
# and even savings withdrawal

class SavingsEntry < ActiveRecord::Base
  attr_accessible :savings_source_id, 
                  :savings_source_type,
                  :amount,
                  :savings_status,
                  :direction,
                  
                  :financial_product_id,
                  :financial_product_type ,
                  :member_id ,
                  :description,
                  :is_confirmed ,
                  :confirmed_at 
                  
  validates_presence_of :direction, :amount, :member_id 
  
  belongs_to :savings_source, :polymorphic => true
  belongs_to :financial_product, :polymorphic => true 
  
  belongs_to :member 
  
  validate :valid_direction_if_independent_savings
  validate :valid_amount 
  validate :valid_withdrawal_amount
  
  def all_fields_for_independent_savings_present?
    direction.present? and 
    amount.present? and 
    member_id.present? 
  end

  def valid_direction_if_independent_savings
    return if not financial_product_id.nil?
    return if not all_fields_for_independent_savings_present?
    
    
    if not [
        FUND_TRANSFER_DIRECTION[:incoming],
        FUND_TRANSFER_DIRECTION[:outgoing]
      ].include?(self.direction)
      self.errors.add(:direction, "Harus memilih tipe transaksi: penambahan atau pengurangan")
      return self 
    end
  end
  
  def valid_amount
    return if not financial_product_id.nil?
    return if not all_fields_for_independent_savings_present?
    
    if amount <= BigDecimal('0')
      self.errors.add(:amount, "Jumlah tidak boleh sama dengan atau lebih kecil dari 0")
      return self
    end
  end
  
  def valid_withdrawal_amount
    
    # puts "Checking valid withdrawal amount\n"*5
    
    return if not financial_product_id.nil?
    # puts "financial product id is nil"
    return if not all_fields_for_independent_savings_present?
    # puts "Every needed data is present"
    
    
    
    if direction == FUND_TRANSFER_DIRECTION[:outgoing]
      # puts "Amount: #{amount}"
      # puts "Total savings: #{member.total_savings_account}"
      if amount > member.total_savings_account
        self.errors.add(:amount, "Tidak boleh lebih besar dari #{member.total_savings_account}")
        return self 
      end
    end
  end
  
=begin
  # Independent savings
=end
  def self.create_object( params ) 
    
    # puts "Inside self.create_object\n"
    new_object = self.new 
    
    new_object.savings_source_id      = nil  
    new_object.savings_source_type    = nil 
    new_object.amount                 = BigDecimal(params[:amount] || '0')
    new_object.savings_status         = SAVINGS_STATUS[:savings_account]
    new_object.direction              = params[:direction]
    new_object.financial_product_id   = nil 
    new_object.financial_product_type = nil
    new_object.member_id              = params[:member_id]
    new_object.save 
     
    return new_object
  end
  
  def self.update_object( params ) 
    
    if self.is_confirmed?
      self.errors.add(:generic_errors, 'Sudah dikonfirmasi. Silakan unconfirm')
      return self 
    end
    
    self.savings_source_id      = nil  
    self.savings_source_type    = nil 
    self.amount                 = BigDecimal(params[:amount] || '0')
    self.savings_status         = SAVINGS_STATUS[:savings_account]
    self.direction              = params[:direction]
    self.financial_product_id   = nil 
    self.financial_product_type = nil
    self.member_id              = params[:member_id]
    
    self.save
  end
  
  def delete_object
    if self.is_confirmed?
      self.errors.add(:generic_errors, 'Sudah dikonfirmasi. Silakan unconfirm')
      return self
    end
    
    self.destroy 
  end
  
  
  def confirm(params)
    if self.is_confirmed?
      self.errors.add(:generic_errors, 'Sudah dikonfirmasi.')
      return self
    end
    
    if params[:confirmed_at].nil? or not params[:confirmed_at].is_a?(DateTime)
      self.errors.add(:confirmed_at, "Harus ada tanggal konfirmasi pembayaran")
      return self 
    end
    
    self.valid_withdrawal_amount
    
    if self.errors.size != 0 
      self.errors.add(:generic_errors, "Tidak cukup untuk melakukan penarikan: #{member.total_savings_account}")
      return self 
    end
    
    
    self.is_confirmed = true
    self.confirmed_at = params[:confirmed_at]
    if self.save
      multiplier = 1 if self.direction == FUND_TRANSFER_DIRECTION[:incoming]
      multiplier = -1 if self.direction == FUND_TRANSFER_DIRECTION[:outgoing]
      member.update_total_savings_account( multiplier  *self.amount )
    end
  end
  
   
  def unconfirm
    if not self.is_confirmed?
      self.errors.add(:generic_errors, 'Belum dikonfirmasi.')
      return self
    end
    self.is_confirmed = false
    self.confirmed_at = nil 
    
    member = self.member 
    multiplier = -1 
    multiplier = 1 if self.direction ==  FUND_TRANSFER_DIRECTION[:outgoing]
    
    member.update_total_savings_account( multiplier  *self.amount )
  end
  
  
=begin
  GROUP LOAN related savings 
=end
  def self.create_group_loan_disbursement_initial_compulsory_savings( savings_source )
    group_loan_membership = savings_source.group_loan_membership
    member = group_loan_membership.member 
    
    new_object = self.create :savings_source_id => savings_source.id,
                        :savings_source_type => savings_source.class.to_s,
                        :amount => savings_source.group_loan_membership.group_loan_product.initial_savings ,
                        :savings_status => SAVINGS_STATUS[:group_loan_compulsory_savings],
                        :direction => FUND_TRANSFER_DIRECTION[:incoming],
                        :financial_product_id => savings_source.group_loan_membership.group_loan_id ,
                        :financial_product_type => savings_source.group_loan_membership.group_loan.class.to_s,
                        :member_id => member.id ,
                        :is_confirmed => true ,
                        :confirmed_at => savings_source.disbursed_at 
                        
    group_loan_membership.update_total_compulsory_savings(new_object.amount)
  end
  
  def self.create_weekly_payment_compulsory_savings( savings_source )
    # puts "Gonna create savings_entry"
    group_loan_membership = savings_source.group_loan_membership
    member = group_loan_membership.member 
    
    new_object = self.create :savings_source_id => savings_source.id,
                        :savings_source_type => savings_source.class.to_s,
                        :amount => savings_source.group_loan_membership.group_loan_product.compulsory_savings ,
                        :savings_status => SAVINGS_STATUS[:group_loan_compulsory_savings],
                        :direction => FUND_TRANSFER_DIRECTION[:incoming],
                        :financial_product_id => savings_source.group_loan_id ,
                        :financial_product_type => savings_source.group_loan.class.to_s,
                        :member_id => member.id ,
                        :is_confirmed => true, 
                        :confirmed_at => savings_source.group_loan_weekly_collection.confirmed_at 
                        
    # puts "The amount: #{new_object.amount}"
    group_loan_membership.update_total_compulsory_savings( new_object.amount)
  end

 
  
  
   
 
  
  def self.create_group_loan_compulsory_savings_withdrawal( savings_source, amount ) 
    # puts "The savings_source: #{savings_source.inspect}"
    group_loan_membership = savings_source.group_loan_membership
    member = group_loan_membership.member
    
    confirmation_time = nil 
    
    if savings_source.class == GroupLoanPrematureClearancePayment
      confirmation_time = savings_source.group_loan_weekly_collection.confirmed_at 
    elsif savings_source.class == DeceasedClearance
      confirmation_time = savings_source.member.deceased_at 
    end
    
    new_object = self.create :savings_source_id => savings_source.id,
                        :savings_source_type => savings_source.class.to_s,
                        :amount => amount  ,
                        :savings_status => SAVINGS_STATUS[:group_loan_compulsory_savings],
                        :direction => FUND_TRANSFER_DIRECTION[:outgoing],
                        :financial_product_id => savings_source.group_loan_id ,
                        :financial_product_type => savings_source.group_loan.class.to_s,
                        :member_id => member.id,
                        :is_confirmed => true, 
                        :confirmed_at => confirmation_time
  
    group_loan_membership.update_total_compulsory_savings(-1* new_object.amount)
  end
  


  def self.create_savings_account_group_loan_premature_clearance_addition( savings_source, amount ) 
    member = savings_source.member

    new_object = self.create :savings_source_id => savings_source.id,
      :savings_source_type => savings_source.class.to_s,
      :amount => amount  ,
      :savings_status => SAVINGS_STATUS[:savings_account],
      :direction => FUND_TRANSFER_DIRECTION[:incoming],
      :financial_product_id =>  savings_source.group_loan.id  ,
      :financial_product_type => savings_source.group_loan.class.to_s ,
      :member_id => member.id,
      :is_confirmed => true, 
      :confirmed_at => savings_source.group_loan_weekly_collection.confirmed_at

    member.update_total_savings_account( new_object.amount)
  end
  
  def self.create_savings_account_group_loan_deceased_addition( savings_source, amount ) 
    # puts "creating savings_account addition because of deceased member"
    member = savings_source.member

    new_object = self.create :savings_source_id => savings_source.id,
      :savings_source_type => savings_source.class.to_s,
      :amount => amount  ,
      :savings_status => SAVINGS_STATUS[:savings_account],
      :direction => FUND_TRANSFER_DIRECTION[:incoming],
      :financial_product_id =>  savings_source.group_loan.id  ,
      :financial_product_type => savings_source.group_loan.class.to_s ,
      :member_id => member.id,
      :is_confirmed => true ,
      :confirmed_at => savings_source.member.deceased_at 

    member.update_total_savings_account( new_object.amount)
  end
  
  
  
  
  def internal_delete_object
    if self.financial_product_id.nil? 
      self.errors.add(:generic_errors, "Can only be used to cancel automated transaction")
      return self 
    end
    
    member = self.member 
    multiplier = -1 
    multiplier = 1 if self.direction ==  FUND_TRANSFER_DIRECTION[:outgoing]
    
    if self.savings_status == SAVINGS_STATUS[:savings_account]
      
      member.update_total_savings_account( multiplier  *self.amount )
    elsif self.savings_status == SAVINGS_STATUS[:group_loan_compulsory_savings]
      glm = savings_source.group_loan_membership
      glm.update_total_compulsory_savings( multiplier * self.amount)
    end
    
    self.destroy 
  end
  
   
    
    
    
  
=begin
  Savings Account related savings : savings withdrawal and savings addition and interest (4% annual), given monthly 
=end

  # def self.create_savings_account_addition( savings_source, amount ) 
  #   member = savings_source.member
  #   
  #   new_object = self.create :savings_source_id => savings_source.id,
  #                       :savings_source_type => savings_source.class.to_s,
  #                       :amount => amount  ,
  #                       :savings_status => SAVINGS_STATUS[:savings_account],
  #                       :direction => FUND_TRANSFER_DIRECTION[:incoming],
  #                       :financial_product_id =>  nil ,
  #                       :financial_product_type => nil ,
  #                       :member_id => member.id
  # 
  #   member.update_total_savings_account( new_object.amount)
  # end
  
  # def self.create_savings_account_withdrawal( savings_source, amount ) 
  #   member = savings_source.member
  #   
  #   new_object = self.create :savings_source_id => savings_source.id,
  #                       :savings_source_type => savings_source.class.to_s,
  #                       :amount => amount  ,
  #                       :savings_status => SAVINGS_STATUS[:savings_account],
  #                       :direction => FUND_TRANSFER_DIRECTION[:outgoing],
  #                       :financial_product_id =>  nil ,
  #                       :financial_product_type => nil ,
  #                       :member_id => member.id
  # 
  #   member.update_total_savings_account( -1* new_object.amount)
  # end
                      
end
