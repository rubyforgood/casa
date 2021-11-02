class CaseContact < ApplicationRecord
  include ByOrganizationScope
  has_paper_trail
  acts_as_paranoid

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
  has_many :followups

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
  scope :casa_org, ->(casa_org_id = nil) {
    joins(:casa_case).where(casa_cases: {casa_org_id: casa_org_id}) if casa_org_id.present?
  }
  scope :occurred_between, ->(start_date = nil, end_date = nil) {
    where("occurred_at BETWEEN ? AND ?", start_date, end_date) if start_date.present? && end_date.present?
  }
  scope :occurred_starting_at, ->(start_date = nil) {
    where("occurred_at >= ?", start_date) if start_date.present?
  }
  scope :occurred_ending_at, ->(end_date = nil) {
    where("occurred_at <= ?", end_date) if end_date.present?
  }
  scope :created_max_ago, ->(time_range = nil) {
    where("created_at > ?", time_range) if time_range.present?
  }
  scope :contact_made, ->(contact_made = nil) {
    where(contact_made: contact_made) if /true|false/.match?(contact_made.to_s)
  }
  scope :has_transitioned, ->(has_transitioned = nil) {
    if /true|false/.match?(has_transitioned.to_s)
      joins(:casa_case).where(casa_cases: {transition_aged_youth: has_transitioned})
    end
  }
  scope :want_driving_reimbursement, ->(want_driving_reimbursement = nil) {
    if /true|false/.match?(want_driving_reimbursement.to_s)
      where(want_driving_reimbursement: want_driving_reimbursement)
    end
  }
  scope :contact_type, ->(contact_type_ids = nil) {
    includes(:contact_types).where("contact_types.id": [contact_type_ids]) if contact_type_ids.present?
  }
  scope :contact_types, ->(contact_type_id_list = nil) {
    contact_type_id_list.reject! { |id| id.blank? }

    return if contact_type_id_list.blank?

    includes(:contact_types).where("contact_types.id": contact_type_id_list)
  }
  scope :contact_type_groups, ->(contact_type_group_ids = nil) {
    # to handle case when passing ids == [''] && ids == nil
    if contact_type_group_ids&.join&.length&.positive?
      joins(contact_types: :contact_type_group)
        .where(contact_type_groups: {id: contact_type_group_ids})
        .group(:id)
    end
  }
  scope :grab_all, ->(current_user) {
    with_deleted if current_user.is_a?(CasaAdmin)
  }

  scope :contact_medium, ->(medium_type) {
    where(medium_type: medium_type) if medium_type.present?
  }

  scope :filter_by_reimbursement_status, ->(boolean) { where reimbursement_complete: boolean }

  scope :sorted_by, ->(sort_option) {
    direction = /desc$/.match?(sort_option) ? "desc" : "asc"

    case sort_option.to_s
    when /^occurred_at/
      order(occurred_at: direction)
    when /^contact_type/
      joins(:contact_types).order(name: direction)
    when /^medium_type/
      order(medium_type: direction)
    when /^want_driving_reimbursement/
      order(want_driving_reimbursement: direction)
    when /^contact_made/
      order(contact_made: direction)
    else
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  filterrific(
    available_filters: [
      :sorted_by,
      :occurred_starting_at,
      :occurred_ending_at,
      :contact_type,
      :contact_made,
      :contact_medium,
      :want_driving_reimbursement
    ]
  )

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

    errors.add(:base, "Must enter miles driven to receive driving reimbursement.")
  end

  def contact_made_chosen
    errors.add(:base, "Must enter whether the contact was made.") if contact_made.nil?
    !contact_made.nil?
  end

  def quarter_editable?
    # case contacts should no longer be editable after the current quarter plus a grace period
    Time.zone.now < occurred_at.end_of_quarter + 30.days
  end

  def check_if_allow_edit
    return if quarter_editable?

    errors.add(:base, message: "cannot edit case contacts created before the current quarter plus 30 days")
  end

  def supervisor_id
    supervisor.id
  end

  def has_casa_case_transitioned
    casa_case.has_transitioned?
  end

  def contact_groups_with_types
    hash = Hash.new { |h, k| h[k] = [] }
    contact_types.each do |contact_type|
      hash[contact_type.contact_type_group.name] << contact_type.name
    end
    hash
  end

  def requested_followup
    followups.requested.first
  end

  def self.options_for_sorted_by
    sorted_by_params.map do |option|
      [I18n.t("models.case_contact.options_for_sorted_by.#{option}"), option]
    end
  end

  private_class_method def self.sorted_by_params
    %i[
      occurred_at_asc
      occurred_at_desc
      contact_type_asc
      contact_type_desc
      medium_type_asc
      medium_type_desc
      want_driving_reimbursement_asc
      want_driving_reimbursement_desc
      contact_made_asc
      contact_made_desc
    ]
  end
end

# == Schema Information
#
# Table name: case_contacts
#
#  id                         :bigint           not null, primary key
#  contact_made               :boolean          default(FALSE)
#  deleted_at                 :datetime
#  duration_minutes           :integer          not null
#  medium_type                :string
#  miles_driven               :integer          default(0), not null
#  notes                      :string
#  occurred_at                :datetime         not null
#  reimbursement_complete     :boolean          default(FALSE)
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
#  index_case_contacts_on_deleted_at    (deleted_at)
#
# Foreign Keys
#
#  fk_rails_...  (casa_case_id => casa_cases.id)
#  fk_rails_...  (creator_id => users.id)
#
