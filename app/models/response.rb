class Response < ActiveRecord::Base
  class_inheritable_accessor :units, :minimum_responses_for_report, :has_options, :field_type, :field_options, :accepts_qualification

  self.units = nil
  self.minimum_responses_for_report = 1
  self.has_options = false
  self.field_type = 'text_box'
  self.field_options = {:size => 40}
  self.accepts_qualification = false

  def self.has_options?
    self.has_options
  end

  def self.accepts_qualification?
    self.accepts_qualification
  end

  belongs_to :question
  belongs_to :participation
  
  validates_presence_of :question
  validates_presence_of :response
  validates_presence_of :unit, :if => Proc.new { |r| r.class.units }
  before_save :convert_to_standard_units

  # Enable after_find by defining this method
  def after_find; end;
  after_find :convert_from_standard_units

  named_scope :from_invitee,
    :include => {:participation => [{:survey => [:invitations]}]}, 
    :conditions => ['participations.participant_type = ? OR (participations.participant_type = ? AND participations.participant_id = surveys.sponsor_id) OR (invitations.invitee_id = participations.participant_id AND participations.participant_type = ?)',
      'Invitation', 
      'Organization', 
      'Organization']
  
  HUMANIZED_ATTRIBUTES = {
    :numerical_response => "Response",
    :textual_response => "Response"
  }

  def self.human_attribute_name(attr)
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  def response_before_type_cast
    @response_before_type_cast || response
  end

  def response=(value)
    self.textual_response = value
  end

  def response
    self.textual_response
  end
  
  private

  def convert_to_standard_units
    if self.class.units && self.unit then
      self.numerical_response = self.unit.convert(self.numerical_response, :from => self.unit, :to => self.class.standard_unit) 
    end
  end

  def convert_from_standard_units
    if !self.unit.blank? && self.class.units then
      self.numerical_response = self.unit.convert(self.numerical_response, :from => self.class.units.standard_unit, :to => self.unit) 
    end
  end

end
