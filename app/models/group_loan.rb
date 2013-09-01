class GroupLoan < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :office 
  has_many :members, :through => :group_loan_memberships 
  has_many :group_loan_memberships 
  has_many :group_loan_weekly_collections 
  
  has_many :group_loan_run_away_receivables
  has_many :group_loan_run_away_receivable_payments 
  
  has_many :group_loan_disbursements 
  has_many :group_loan_port_compulsory_savings 
  
  has_many :savings_entries, :as => :financial_product 
  
  
  has_many :group_loan_weekly_tasks # weekly payment, weekly attendance  
  validates_presence_of   :name,
                          :number_of_meetings
                          
  validates_uniqueness_of :name 
  
  
  def self.create_object(  params)
    new_object = self.new
    
    new_object.name                            = params[:name] 
    new_object.number_of_meetings = params[:number_of_meetings]
    
    new_object.save
    
    return new_object 
  end
  
  def self.update_object( params ) 
    return nil if self.is_started?  
      
    self.name                            = params[:name] 
    self.number_of_meetings = params[:number_of_meetings]
    
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
      # GROUP_LOAN_DEACTIVATION_CASE
      return self.group_loan_memberships.where{
        (is_active.eq false ) & 
        ( deactivation_case.eq GROUP_LOAN_DEACTIVATION_CASE[:finished_group_loan] )
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
    self.number_of_collections = self.loan_duration 
    self.save 
   
  end 
  
=begin
Phase: loan disbursement finalization
=end
 
   
  def execute_loan_disbursement_payment
    self.active_group_loan_memberships.each do |glm|
      GroupLoanDisbursement.create :group_loan_membership_id => glm.id , :group_loan_id => self.id 
    end
  end
  
  def schedule_group_loan_weekly_collection
    (1..self.number_of_collections).each do |week_number|
      GroupLoanWeeklyCollection.create :group_loan_id => self.id, :week_number => week_number
    end
  end

  def disburse_loan 
    
    if not self.is_loan_disbursement_phase?  
      errors.add(:generic_errors, "Bukan di fase penyerahan pinjaman")
      return self
    end
    
    if self.is_loan_disbursed?
      errors.add(:generic_errors, "Pinjaman keuangan sudah di finalisasi")
      return self
    end
    
    
    
    self.is_loan_disbursed = true 
    self.save 
    
    
    self.execute_loan_disbursement_payment 
    
    
    self.schedule_group_loan_weekly_collection 

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
  
  def has_unconfirmed_weekly_collection?
    self.group_loan_weekly_collections.where(:is_confirmed => false, :is_collected => true).count != 0 
  end
  
  def first_uncollected_weekly_collection
    self.group_loan_weekly_collections.where(:is_confirmed => false, :is_collected => false).order("id ASC").first 
  end
  
=begin
  WeeklyCollection Finish 
=end

  def total_compulsory_savings
    self.active_group_loan_memberships.sum("total_compulsory_savings")
  end


  def deduct_compulsory_savings_for_unsettled_default
    total_amount = BigDecimal('0')
    # The defaults: 
    # 1. run_away_receivable (end_of_cycle payment) 
    # 2. uncollected weekly payment 
    
    
    #### HANDLING THE DEFAULTS 1: run_away_receivable 
    # cases: 
    # 0. no run_away_receivable
    # 1. only one run_away_receivable
    # 2. many run_away_receivable 
    
    total_amount += self.group_loan_run_away_receivables.
        where(:payment_case => GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:end_of_cycle]).
        sum('amount_receivable')
        
    # and add the uncollected weekly payment 
    
    # total_amount += 
    
    
    # what is the minimum denomination? 500 rupiah
    amount_to_be_deducted  = BigDecimal('0')
    if self.total_compulsory_savings < total_amount 
      amount_to_be_deducted = self.total_compulsory_savings
    else # case total_compulsory_savings => total_amount 
      amount_to_be_deducted = total_amount
    end
    
    
    # then, gonna split this amount to all members.  
    # round off to 500 rupiah? copy from kkims 
    # if member's compulsory savings is not sufficient, count that loss as office's 
    
  end
  
  def port_compulsory_savings_to_voluntary_savings
    self.active_group_loan_memberships.each do |glm|
      GroupLoanPortCompulsorySavings.create :group_loan_id => self.id, 
                                  :group_loan_membership_id => glm.id ,
                                  :member_id => glm.member_id 
    end
  end 
  
  def deactivate_group_loan_memberships_due_to_group_closed
    self.active_group_loan_memberships.each do |glm|
      glm.is_active = false 
      glm.deactivation_case = GROUP_LOAN_DEACTIVATION_CASE[:finished_group_loan]
      glm.save 
    end
  end
  
  def close
    if self.group_loan_weekly_collections.where(:is_confirmed => true, :is_collected => true).count != self.number_of_collections
      self.errors.add(:generic_errors, "Ada Pengumpulan mingguan yang belum selesai")
      return self 
    end
    
    if self.is_closed?
      self.errors.add(:generic_errors, "Sudah ditutup")
      return self 
    end
    
    
    
    # perform deduction for those unpaid member
    self.deduct_compulsory_savings_for_unsettled_default
    self.port_compulsory_savings_to_voluntary_savings 
    self.deactivate_group_loan_memberships_due_to_group_closed
    
    # self.close_group_loan_run_away_receivable # the receivable is being written off:
    # 1. loan portfolio will be provisioned
    # 2. the interest receivable will be written-off (as expense) 
    
    self.is_closed = true 
    self.save
  end

 
 
end