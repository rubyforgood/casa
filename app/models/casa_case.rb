class CasaCase < ApplicationRecord
  include ByOrganizationScope
  include DateHelper
  extend FriendlyId

  self.ignored_columns = %w[transition_aged_youth court_report_due_date]

  attr_accessor :validate_contact_type

  TABLE_COLUMNS = %w[
    case_number
    hearing_type_name
    judge_name
    status
    birth_month_year_youth
    assigned_to
    actions
  ].freeze

  TRANSITION_AGE = 14
  TRANSITION_AGE_YOUTH_ICON = "🦋".freeze
  NON_TRANSITION_AGE_YOUTH_ICON = "🐛".freeze

  friendly_id :case_number, use: :scoped, scope: :casa_org

  has_many :case_assignments, dependent: :destroy
  has_many(:volunteers, through: :case_assignments, source: :volunteer, class_name: "User")
  has_many :active_case_assignments, -> { active }, class_name: "CaseAssignment"
  has_many :assigned_volunteers, -> { active }, through: :active_case_assignments, source: :volunteer, class_name: "Volunteer"
  has_many :case_contacts, dependent: :destroy
  has_many :casa_case_emancipation_categories, dependent: :destroy
  has_many :emancipation_categories, through: :casa_case_emancipation_categories
  has_many :casa_cases_emancipation_options, dependent: :destroy
  has_many :emancipation_options, through: :casa_cases_emancipation_options
  has_many :court_dates, dependent: :destroy
  has_many :placements, dependent: :destroy
  has_many :case_group_memberships
  has_many :case_groups, through: :case_group_memberships
  has_many_attached :court_reports

  validates :case_number, uniqueness: {scope: :casa_org_id, case_sensitive: false}, presence: true
  belongs_to :hearing_type, optional: true
  belongs_to :judge, optional: true
  belongs_to :casa_org
  validates :birth_month_year_youth, presence: true
  has_many :casa_case_contact_types
  has_and_belongs_to_many :contact_types, join_table: "casa_case_contact_types"
  accepts_nested_attributes_for :court_dates
  accepts_nested_attributes_for :volunteers

  has_many :case_court_orders, -> { order "id asc" }, dependent: :destroy
  accepts_nested_attributes_for :case_court_orders, reject_if: :all_blank, allow_destroy: true

  enum court_report_status: {not_submitted: 0, submitted: 1, in_review: 2, completed: 3}, _prefix: :court_report

  scope :ordered, -> { order(updated_at: :desc) }
  scope :actively_assigned_to, ->(volunteer) {
    joins(:case_assignments).where(
      case_assignments: {volunteer: volunteer, active: true}
    )
  }
  scope :actively_assigned_excluding_volunteer, ->(volunteer) {
    joins(:case_assignments)
      .where(case_assignments: {active: true})
      .where.not(case_assignments: {volunteer: volunteer})
      .where(casa_org: volunteer.casa_org)
      .order(:case_number)
  }
  scope :not_assigned, ->(casa_org) {
    where(casa_org_id: casa_org.id)
      .left_outer_joins(:case_assignments)
      .where("case_assignments.id IS NULL OR NOT case_assignments.active")
      .order(:case_number)
  }
  scope :should_transition, -> {
    where("birth_month_year_youth <= ?", TRANSITION_AGE.years.ago)
  }

  scope :birthday_next_month, -> {
    where("EXTRACT(month from birth_month_year_youth) = ?", DateTime.now.next_month.month)
  }

  scope :due_date_passed, -> {
    # No more future court dates
    where.not(id: CourtDate.where("date >= ?", Date.today).pluck(:casa_case_id))
  }

  scope :is_transitioned, -> {
    where("birth_month_year_youth < ?", TRANSITION_AGE.years.ago)
  }

  scope :active, -> {
    where(active: true)
  }

  scope :inactive, -> {
    where(active: false)
  }

  scope :missing_court_dates, -> {
    where.missing(:court_dates)
  }

  delegate :name, to: :hearing_type, prefix: true, allow_nil: true
  delegate :name, to: :judge, prefix: true, allow_nil: true

  # Validation to check timestamp and submission status of a case
  validates_with CourtReportValidator, fields: [:court_report_status, :court_report_submitted_at]

  def add_emancipation_category(category_id)
    emancipation_categories << EmancipationCategory.find(category_id)
  end

  def add_emancipation_option(option_id)
    option = EmancipationOption.find(option_id)
    option_category = option.emancipation_category

    if !(option_category.mutually_exclusive && EmancipationOption.options_with_category_and_case(option_category, id).any?)
      emancipation_options << option
    else
      raise "Attempted adding multiple options belonging to a mutually exclusive category"
    end
  end

  def clear_court_dates
    if next_court_date.nil?
      update(
        court_report_status: :not_submitted
      )
    end
  end

  def court_report_status=(value)
    super
    if court_report_not_submitted?
      self.court_report_submitted_at = nil
    else
      self.court_report_submitted_at ||= Time.current
    end
    court_report_status
  end

  def in_transition_age?
    birth_month_year_youth.nil? ? false : birth_month_year_youth <= TRANSITION_AGE.years.ago
  end

  def latest_court_report
    court_reports.order("created_at").last
  end

  def next_court_date
    court_dates.where("date >= ?", Date.today).order(:date).first
  end

  def most_recent_past_court_date
    court_dates.where("date < ?", Date.today).order(:date).last
  end

  def has_judge_name?
    judge_name
  end

  def remove_emancipation_category(category_id)
    category = EmancipationCategory.find(category_id)
    raise ActiveRecord::RecordNotFound unless emancipation_categories.include?(category)

    emancipation_categories.destroy(category)
  end

  def remove_emancipation_option(option_id)
    option = EmancipationOption.find(option_id)
    raise ActiveRecord::RecordNotFound unless emancipation_options.include?(option)

    emancipation_options.destroy(option)
  end

  def update_cleaning_contact_types(args)
    args = parse_date(errors, "court_report_due_date", args)

    return false unless errors.messages.empty?

    transaction do
      casa_case_contact_types.destroy_all
      update!(args)
    rescue ActiveRecord::RecordInvalid
      raise ActiveRecord::Rollback
    end
  end

  def deactivate
    update(active: false)
    case_assignments.map { |ca| ca.update(active: false) }
  end

  def reactivate
    update(active: true)
  end

  def unassigned_volunteers
    volunteers_unassigned_to_case = Volunteer.active.where.not(id: assigned_volunteers).in_organization(casa_org)
    volunteers_unassigned_to_case.with_no_assigned_cases + volunteers_unassigned_to_case.with_assigned_cases
  end

  def full_attributes_hash
    attributes.symbolize_keys.merge({contact_types: contact_types.reload.map(&:attributes), court_orders: case_court_orders.map(&:attributes)})
  end

  def contact_type_validation?
    validate_update
  end

  def should_generate_new_friendly_id?
    case_number_changed? || super
  end
end

# == Schema Information
#
# Table name: casa_cases
#
#  id                        :bigint           not null, primary key
#  active                    :boolean          default(TRUE), not null
#  birth_month_year_youth    :datetime
#  case_number               :string           not null
#  court_report_status       :integer          default("not_submitted")
#  court_report_submitted_at :datetime
#  date_in_care              :datetime
#  slug                      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  casa_org_id               :bigint           not null
#
# Indexes
#
#  index_casa_cases_on_casa_org_id                  (casa_org_id)
#  index_casa_cases_on_case_number_and_casa_org_id  (case_number,casa_org_id) UNIQUE
#  index_casa_cases_on_slug                         (slug)
#
# Foreign Keys
#
#  fk_rails_...  (casa_org_id => casa_orgs.id)
#
