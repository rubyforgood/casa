class CaseContact < ApplicationRecord
  include ByOrganizationScope
  acts_as_paranoid

  attr_accessor :duration_hours

  validates :contact_made, inclusion: {in: [true, false], message: :must_be_true_or_false}
  validates :miles_driven, numericality: {greater_than_or_equal_to: 0, less_than: 10000}
  validates :medium_type, presence: true, if: :active_or_details?
  validates :duration_minutes, presence: true, if: :active_or_details?
  validates :occurred_at, presence: true, if: :active_or_details?
  MINIMUM_DATE = "1989-01-01".to_date
  validates :occurred_at, comparison: {
    greater_than_or_equal_to: MINIMUM_DATE,
    message: "can't be prior to #{I18n.l(MINIMUM_DATE)}.",
    allow_nil: true
  }
  # NOTE: 'extra' day is a temporary fix for user selecting current date, but this validation failing
  validates :occurred_at, comparison: {
    less_than: Time.zone.tomorrow + 1.day,
    message: :cant_be_future,
    allow_nil: true
  }
  validate :reimbursement_only_when_miles_driven, if: :active_or_details?
  validate :volunteer_address_when_reimbursement_wanted, if: :active_or_details?
  validate :volunteer_address_is_valid, if: :active_or_details?

  belongs_to :creator, class_name: "User"
  has_one :supervisor_volunteer, -> {
    where(is_active: true)
  }, primary_key: :creator_id, foreign_key: :volunteer_id
  has_one :supervisor, through: :creator
  has_many :followups

  # Draft casa_case_id is nil until active
  belongs_to :casa_case, optional: true
  has_one :casa_org, through: :casa_case
  # Use creator_casa_org as fallback org relationship for drafts
  has_one :creator_casa_org, through: :creator, source: :casa_org
  validates :casa_case_id, presence: true, if: :active?
  validates :draft_case_ids, presence: {message: :must_be_selected}, if: :active_or_details?

  has_many :case_contact_contact_types
  validates :case_contact_contact_types, presence: {message: :must_be_selected}, if: :active_or_details?
  has_many :contact_types, through: :case_contact_contact_types

  has_many :additional_expenses
  has_many :contact_topic_answers, dependent: :destroy
  has_many :contact_topics, through: :contact_topic_answers

  after_save_commit ::CaseContactMetadataCallback.new

  # NOTE: 'notes' & 'expenses' statuses are no longer used. Could be removed from enum if
  # existing records are migrated to started/details status (draft).
  # NOTE: enum defines methods (active?) and scopes (.active, .not_active) for each member
  enum :status, {
    started: "started",
    active: "active",
    details: "details",
    notes: "notes",
    expenses: "expenses"
  }, validate: true, default: :started

  def active_or_details?
    details? || active?
  end

  def active_or_expenses?
    expenses? || active?
  end

  def active_or_notes?
    notes? || active?
  end

  accepts_nested_attributes_for :additional_expenses, reject_if: :all_blank, allow_destroy: true

  accepts_nested_attributes_for :contact_topic_answers, allow_destroy: true,
    reject_if: proc { |attrs| attrs["contact_topic_id"].blank? && attrs["value"].blank? }  # .notes sent without topic_id, but must have a value.

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
    where("case_contacts.created_at > ?", time_range) if time_range.present?
  }
  scope :contact_made, ->(contact_made = nil) {
    where(contact_made: contact_made) if /true|false/.match?(contact_made.to_s)
  }
  scope :has_transitioned, ->(has_transitioned = nil) {
    if /true|false/.match?(has_transitioned.to_s)
      operator = has_transitioned ? "<=" : ">"

      joins(:casa_case).where("casa_cases.birth_month_year_youth #{operator} ?", CasaCase::TRANSITION_AGE.years.ago)
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
    with_deleted if current_user.is_a?(CasaAdmin) # TODO since this cases on user type it should be in a Policy file
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
      joins(:contact_types).merge(ContactType.order(name: direction))
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

  scope :with_casa_case, ->(case_ids) {
    where(casa_case_id: case_ids) if case_ids.present?
  }

  scope :no_drafts, ->(checked) { (checked == 1) ? active : all }

  scope :with_metadata_pair, ->(key, value) { where("metadata -> ? @> ?::jsonb", key.to_s, value.to_s) }
  scope :used_create_another, -> { with_metadata_pair(:create_another, true) }

  filterrific(
    default_filter_params: {sorted_by: "occurred_at_desc"},
    available_filters: [
      :sorted_by,
      :occurred_starting_at,
      :occurred_ending_at,
      :contact_type,
      :contact_made,
      :contact_medium,
      :want_driving_reimbursement,
      :no_drafts
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
      contact_types.clear
      update(args)
    end
  end

  # Displays occurred_at in the format January 1, 1970
  # @return [String]
  def occurred_at_display
    occurred_at.strftime("%B %-d, %Y")
  end

  # Returns the mileage rate if the casa_org has a mileage_rate for the date of the contact. Otherwise returns nil.
  # @return [BigDecimal, nil]
  def reimbursement_amount
    mileage_rate = casa_case.casa_org.mileage_rate_for_given_date(occurred_at.to_datetime)
    return nil unless mileage_rate

    mileage_rate * miles_driven
  end

  def reimbursement_only_when_miles_driven
    return if miles_driven&.positive? || !want_driving_reimbursement

    errors.add(:base, "Must enter miles driven to receive driving reimbursement.")
  end

  def volunteer_address_when_reimbursement_wanted
    if want_driving_reimbursement && volunteer_address&.empty?
      errors.add(:base, "Must enter a valid mailing address for the reimbursement.")
    end
  end

  def volunteer_address_is_valid
    if volunteer_address&.present?
      if Address.new(user_id: creator.id, content: volunteer_address).invalid?
        errors.add(:base, "The volunteer's address is not valid.")
      end
    end
  end

  def supervisor_id
    supervisor.id
  end

  def has_casa_case_transitioned
    casa_case.in_transition_age?
  end

  def contact_groups_with_types
    hash = Hash.new { |h, k| h[k] = [] }
    contact_types.includes(:contact_type_group).each do |contact_type|
      hash[contact_type.contact_type_group.name] << contact_type.name
    end
    hash
  end

  def requested_followup
    followups.find(&:requested?)
  end

  def should_send_reimbursement_email?
    want_driving_reimbursement? && supervisor_active?
  end

  def supervisor_active?
    !supervisor.blank? && supervisor.active?
  end

  def address_field_disabled?
    !volunteer
  end

  def volunteer
    if creator.is_a?(Volunteer)
      creator
    elsif draft_case_ids.first && CasaCase.find(draft_case_ids.first).volunteers.count == 1
      CasaCase.find(draft_case_ids.first).volunteers.first
    end
  end

  def self.options_for_sorted_by
    sorted_by_params.each.map { |option_pair| option_pair.reverse }
  end

  def self.case_hash_from_cases(cases)
    casa_case_ids = cases.map(&:draft_case_ids).flatten.uniq.sort
    casa_case_ids.each_with_object({}) do |casa_case_id, hash|
      hash[casa_case_id] = cases.select { |c| c.casa_case_id == casa_case_id || c.draft_case_ids.include?(casa_case_id) }
    end
  end

  def casa_org_any_expenses_enabled?
    creator.casa_org.additional_expenses_enabled || creator.casa_org.show_driving_reimbursement
  end

  private_class_method def self.sorted_by_params
    {
      occurred_at_asc: "Date of contact (oldest first)",
      occurred_at_desc: "Date of contact (newest first)",
      contact_type_asc: "Contact type (A-z)",
      contact_type_desc: "Contact type (z-A)",
      medium_type_asc: "Contact medium (A-z)",
      medium_type_desc: "Contact medium (z-A)",
      want_driving_reimbursement_asc: "Want driving reimbursement ('no' first)",
      want_driving_reimbursement_desc: "Want driving reimbursement ('yes' first)",
      contact_made_asc: "Contact made ('no' first)",
      contact_made_desc: "Contact made ('yes' first)"
    }
  end
end

# == Schema Information
#
# Table name: case_contacts
#
#  id                         :bigint           not null, primary key
#  contact_made               :boolean          default(FALSE)
#  deleted_at                 :datetime
#  draft_case_ids             :integer          default([]), is an Array
#  duration_minutes           :integer
#  medium_type                :string
#  metadata                   :jsonb
#  miles_driven               :integer          default(0), not null
#  notes                      :string
#  occurred_at                :datetime
#  reimbursement_complete     :boolean          default(FALSE)
#  status                     :string           default("started")
#  volunteer_address          :string
#  want_driving_reimbursement :boolean          default(FALSE)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  casa_case_id               :bigint
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
