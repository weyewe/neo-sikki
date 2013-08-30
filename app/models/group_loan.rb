class GroupLoan < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :office 
  has_many :members, :through => :group_loan_memberships 
  has_many :group_loan_memberships 
  has_many :sub_group_loans 
  has_one :group_loan_default_payment 
  
  has_many :savings_entries, :as => :financial_product 
  has_many :group_loan_backlogs
  has_many :group_loan_grace_payments 
  
  
  has_many :group_loan_weekly_tasks # weekly payment, weekly attendance  
  validates_presence_of :office_id , :name,
                          :is_auto_deduct_admin_fee,
                          :is_auto_deduct_initial_savings, 
                          :is_compulsory_weekly_attendance
                          
  validates_uniqueness_of :name 
  
  
  def self.create_object(  params)
    new_object = self.new
    
    new_object.office_id = params[:office_id ]
    new_object.name                            = params[:name]
    new_object.is_auto_deduct_admin_fee        = true # params[:is_auto_deduct_admin_fee]
    new_object.is_auto_deduct_initial_savings  = true # params[:is_auto_deduct_initial_savings]
    new_object.is_compulsory_weekly_attendance = true 
    
    new_object.save
    
    return new_object 
  end
  
  def self.update_object( params ) 
    return nil if self.is_started?  
      
    self.name                            = params[:name]
    self.is_auto_deduct_admin_fee        = true #params[:is_auto_deduct_admin_fee]
    self.is_auto_deduct_initial_savings  = true #params[:is_auto_deduct_initial_savings]
    self.is_compulsory_weekly_attendance = true 
    
    self.save
    
    return self
  end
  
  
  def has_membership?( group_loan_membership)
    active_glm_id_list = self.active_group_loan_memberships.map {|x| x.id }
    
    active_glm_id_list.include?( group_loan_membership.id )
  end
  
  def set_group_leader( group_loan_membership ) 
    self.errors.add(:group_leader_id, "Harap pilih anggota dari group ini") if group_loan_membership.nil? 
    
     
    if self.has_membership?( group_loan_membership )  
      self.group_leader_id = group_loan_membership.id 
      self.save 
    else
      self.errors.add(:group_leader_id, "Bukan anggota dari pinjaman group ini")
    end
  end
  
  def active_group_loan_memberships
    if not self.is_closed?
      return self.group_loan_memberships.where(:is_active => true )
    else
      return self.group_loan_memberships.where{
        (is_active.eq false ) and 
        ( deactivation_status.eq GROUP_LOAN_DEACTIVATION_STATUS[:finished_group_loan] )
      }
    end 
  end
   
   
  def all_group_loan_memberships_have_equal_duration?
    duration_array = [] 
    self.active_group_loan_memberships.each do |glm|
      return false if glm.group_loan_product.nil?
      duration_array << glm.group_loan_product.total_weeks 
    end
    
    return false if duration_array.uniq.length != 1
    return true 
  end
  
=begin
  Encode the group loan phases
=end

  def is_financial_education_phase?
    is_started? and 
    not is_financial_education_finalized? and
    not is_loan_disbursement_finalized? and 
    not is_weekly_payment_period_closed? and 
    not is_grace_period_payment_closed?  and 
    not is_default_payment_period_closed? and 
    not is_closed? 
  end
  
  def is_loan_disbursement_phase? 
    is_started? and 
    is_financial_education_finalized? and
    not is_loan_disbursement_finalized? and 
    not is_weekly_payment_period_closed? and 
    not is_grace_period_payment_closed? and 
    not is_default_payment_period_closed? and 
    not is_closed?
  end
  
  def is_weekly_payment_period_phase?
    is_started? and 
    is_financial_education_finalized? and
    is_loan_disbursement_finalized? and 
    not is_weekly_payment_period_closed? and 
    not is_grace_period_payment_closed? and 
    not is_default_payment_period_closed? and 
    not is_closed?
  end
  
  def is_grace_payment_period_phase?
    is_started? and 
    is_financial_education_finalized? and
    is_loan_disbursement_finalized? and 
    is_weekly_payment_period_closed? and 
    not is_grace_period_payment_closed? and 
    not is_default_payment_period_closed? and 
    not is_closed?
  end
  
  def is_default_payment_resolution_phase?
    is_started? and 
    is_financial_education_finalized? and
    is_loan_disbursement_finalized? and 
    is_weekly_payment_period_closed? and 
    is_grace_period_payment_closed? and 
    not is_default_payment_period_closed? and 
    not is_closed? 
  end
  
  def is_closing_phase?
    is_started? and 
    is_financial_education_finalized? and
    is_loan_disbursement_finalized? and 
    is_weekly_payment_period_closed? and 
    is_grace_period_payment_closed? and 
    is_default_payment_period_closed? and 
    not is_closed? 
  end
   
   
=begin
  Switching phases 
=end
  def start
     
    if  self.is_started?
      errors.add(:generic_errors, "Pinjaman grup sudah dimulai")
      return self 
    end
    
    if self.group_loan_memberships.count == 0 
      errors.add(:generic_errors, "Jumlah anggota harus lebih besar dari 0")
      return self 
    end
    
    if not self.all_group_loan_memberships_have_equal_duration?
      errors.add(:generic_errors, "Durasi pinjaman harus sama")
      return self 
    end
    
    self.is_started = true
    self.save 
   
  end 
  
=begin
Phase: loan disbursement finalization
=end
 
  
  def deactivate_memberships_for_absentee_in_loan_disbursement
    self.active_group_loan_memberships.where(:is_attending_loan_disbursement => false).each do |glm|
      glm.is_active = false 
      glm.deactivation_status = GROUP_LOAN_DEACTIVATION_STATUS[:loan_disbursement_absent]
      glm.save
    end
  end
  
  def execute_loan_disbursement_payment
    self.active_group_loan_memberships.each do |glm|
      GroupLoanDisbursement.create :group_loan_membership_id => glm.id 
    end
  end

  def finalize_loan_disbursement
    
    if not self.is_loan_disbursement_phase?  
      errors.add(:generic_errors, "Bukan di fase penyerahan pinjaman")
      return self
    end
    
    if self.is_loan_disbursement_finalized?
      errors.add(:generic_errors, "Pinjaman keuangan sudah di finalisasi")
      return self
    end
    
    if not self.is_all_loan_disbursement_attendances_marked?
      errors.add(:generic_errors, "Ada anggota yang kehadirannya di penyerahan pinjaman belum ditandai")
      return self
    end
    
    self.is_loan_disbursement_finalized = true 
    self.save 
    
    
    self.execute_loan_disbursement_payment 

    # create GroupLoanWeeklyCollection  => it has many weird cases. new problem domain on that model.
  end
  
  
=begin
  WeeklyCollection 
=end

  def loan_duration
    duration_array = []
    self.active_group_loan_memberships.each do |glm|
      duration_array << glm.group_loan_product.total_weeks
    end
    
    return duration_array.uniq.first  
  end
  
=begin
  WeeklyCollection Finish 
=end

 
 
end