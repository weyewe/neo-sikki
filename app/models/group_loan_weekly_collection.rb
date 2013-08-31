class GroupLoanWeeklyCollection < ActiveRecord::Base
  attr_accessible :group_loan_id, :week_number 
  belongs_to :group_loan 
  validates_presence_of :group_loan_id, :week_number 
  
  
  def first_non_collected?
    group_loan.group_loan_weekly_collection.where(
      :is_collected => false 
    )
  end
  
  def collect(params)
    if self.is_collected?
      self.errors.add(:generic_errors, "Sudah melakukan pengumpulan untuk minggu #{self.week_number}")
      return self 
    end
    
    if self.group_loan.has_unconfirmed_weekly_collection?
      self.errors.add(:generic_errors, "Ada pembayaran mingguan yang belum di konfirmasi")
      return self
    end
    
    first_uncollected_weekly_collection = self.group_loan.first_uncollected_weekly_collection
    if  first_uncollected_weekly_collection and 
        self.id  != first_uncollected_weekly_collection.id 
      self.errors.add(:generic_errors, "Pembayaran di minggu #{first_uncollected_weekly_collection.week_number} belum dilakukan")
      return self
    end
    
    self.collection_datetime = params[:collection_datetime]
    
    if self.collection_datetime.present?
      self.is_collected = true 
    end
    
    self.save 
  end
  
  def create_group_loan_weekly_payments
    # do weekly payment for all active members
    # minus those that can't pay  (the dead and running away is considered as non active)    
    active_glm_id_list = group_loan.active_group_loan_memberships.map {|x| x.id }
    no_payment_id_list = []
    
    active_glm_id_list -= no_payment_id_list 
    
    active_glm_id_list.each do |glm_id|
      GroupLoanWeeklyPayment.create :group_loan_membership_id => glm_id,
                                    :group_loan_id => self.group_loan_id,
                                    :group_loan_weekly_collection_id => self.id 
    end
  end
  
  def confirm
    if not self.is_collected?
      self.errors.add(:generic_errors, "Belum melakukan pengumpulan di minggu ini")
      return self 
    end
    
    if self.is_collected? and self.is_confirmed?
      self.errors.add(:generic_errors, "Sudah dikonfirmasi")
      return self 
    end
    
    
    self.confirmation_datetime = DateTime.now 
    self.is_confirmed = true 
    self.save 
    
    self.create_group_loan_weekly_payments 
  end
   
end
