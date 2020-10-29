class CaseContact < ApplicationRecord
  attr_accessor :duration_hours

  validate :contact_made_chosen
  validates :duration_minutes, numericality: {greater_than_or_equal_to: 15, message: "Minimum case contact duration should be 15 minutes."}
  validates :miles_driven, numericality: {greater_than_or_equal_to: 0, less_than: 10000}
  validates :medium_type, presence: true
  validates :occurred_at, presence: true
  validate :occurred_at_not_in_future
  validate :reimbursement_only_when_miles_driven
  validate :check_if_allow_edit, on: :update

  belongs_to :creator, class_name: "User"
  has_one :supervisor_volunteer, -> {
    where(is_active: true)
  }, primary_key: :creator_id, foreign_key: :volunteer_id
  has_one :supervisor, through: :creator

  belongs_to :casa_case

  has_many :case_contact_contact_type
  has_many :contact_types, through: :case_contact_contact_type, source: :contact_type

  accepts_nested_attributes_for :case_contact_contact_type

  scope :supervisors, ->(supervisor_ids = nil) {
    joins(:supervisor_volunteer).where(supervisor_volunteers: {supervisor_id: supervisor_ids}) if supervisor_ids.present?
  }
  scope :creators, ->(creator_ids = nil) {
    where(creator_id: creator_ids) if creator_ids.present?
  }
  scope :occurred_between, ->(start_date = nil, end_date = nil) {
    where("occurred_at BETWEEN ? AND ?", start_date, end_date) if start_date.present? && end_date.present?
  }
  scope :contact_made, ->(contact_made = nil) {
    where(contact_made: contact_made) if contact_made == true || contact_made == false
  }
  scope :has_transitioned, ->(has_transitioned = nil) {
    joins(:casa_case).where(casa_cases: {transition_aged_youth: has_transitioned}) if has_transitioned == true || has_transitioned == false
  }
  scope :want_driving_reimbursement, ->(want_driving_reimbursement = nil) {
    where(want_driving_reimbursement: want_driving_reimbursement) if want_driving_reimbursement == true || want_driving_reimbursement == false
  }
  scope :contact_type, ->(contact_type_ids = nil) {
    includes(:contact_types).where("contact_types.id": [contact_type_ids]) if contact_type_ids.present?
  }
  scope :contact_type_groups, ->(contact_type_group_ids = nil) {
    # to handle case when passing ids == [''] && ids == nil
    if contact_type_group_ids&.join&.length&.positive?
      joins(contact_types: :contact_type_group)
        .where(contact_type_groups: {id: contact_type_group_ids})
        .group(:id)
    end
  }

  IN_PERSON = "in-person".freeze
  TEXT_EMAIL = "text/email".freeze
  VIDEO = "video".freeze
  VOICE_ONLY = "voice-only".freeze
  LETTER = "letter".freeze
  CONTACT_MEDIUMS = [IN_PERSON, TEXT_EMAIL, VIDEO, VOICE_ONLY, LETTER].freeze

  def update_cleaning_contact_types(args)
    transaction do
      case_contact_contact_type.destroy_all
      update(args)
    end
  end

  def occurred_at_not_in_future
    return unless occurred_at && occurred_at >= Date.tomorrow

    errors.add(:occurred_at, :invalid, message: "cannot be in the future")
  end

  def reimbursement_only_when_miles_driven
    return if miles_driven&.positive? || !want_driving_reimbursement

    errors[:base] << "Must enter miles driven to receive driving reimbursement."
  end

  def contact_made_chosen
    errors[:base] << "Must enter whether the contact was made." if contact_made.nil?
    !contact_made.nil?
  end

  def created_in_current_quarter?
    today = Time.zone.now
    occurred_at.end_of_quarter > today
  end

  def check_if_allow_edit
    return if created_in_current_quarter?

    errors[:base] << "cannot edit case contacts created before the current quarter"
  end

  def supervisor_id
    supervisor.id
  end

  def has_casa_case_transitioned
    casa_case.has_transitioned?
  end
end

# == Schema Information
#
# Table name: case_contacts
#
#  id                         :bigint           not null, primary key
#  contact_made               :boolean          default(FALSE)
#  duration_minutes           :integer          not null
#  medium_type                :string
#  miles_driven               :integer          default(0), not null
#  notes                      :string
#  occurred_at                :datetime         not null
#  want_driving_reimbursement :boolean          default(FALSE)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  casa_case_id               :bigint           not null
#  creator_id                 :bigint           not null
#
# Indexes
#
#  index_case_contacts_on_casa_case_id  (casa_case_id)
#  index_case_contacts_on_creator_id    (creator_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_case_id => casa_cases.id)
#  fk_rails_...  (creator_id => users.id)
#
