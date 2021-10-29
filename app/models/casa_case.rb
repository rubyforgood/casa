class CasaCase < ApplicationRecord
  include ByOrganizationScope
  include DateHelper

  has_paper_trail

  TABLE_COLUMNS = %w[
    case_number
    hearing_type_name
    judge_name
    status
    transition_aged_youth
    assigned_to
    actions
  ].freeze

  TRANSITION_AGE_YOUTH_ICON = "🦋".freeze
  NON_TRANSITION_AGE_YOUTH_ICON = "🐛".freeze

  has_paper_trail

  before_create :set_slug

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
  has_many_attached :court_reports

  validates :case_number, uniqueness: {scope: :casa_org_id, case_sensitive: false}, presence: true
  belongs_to :hearing_type, optional: true
  belongs_to :judge, optional: true
  belongs_to :casa_org
  validates :birth_month_year_youth, presence: true

  has_many :casa_case_contact_types
  has_many :contact_types, through: :casa_case_contact_types, source: :contact_type
  accepts_nested_attributes_for :casa_case_contact_types

  has_many :case_court_orders, -> { order "id asc" }, dependent: :destroy
  accepts_nested_attributes_for :case_court_orders, reject_if: :all_blank

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
    where(transition_aged_youth: false)
      .where("birth_month_year_youth <= ?", 14.years.ago)
  }

  scope :due_date_passed, -> {
    # No more future court dates
    where.not(id: CourtDate.where("date >= ?", Date.today).pluck(:casa_case_id))
  }

  scope :active, -> {
    where(active: true)
  }

  scope :inactive, -> {
    where(active: false)
  }

  delegate :name, to: :hearing_type, prefix: true, allow_nil: true
  delegate :name, to: :judge, prefix: true, allow_nil: true

  # Validation to check timestamp and submission status of a case
  validates_with CourtReportValidator, fields: [:court_report_status, :court_report_submitted_at]

  def add_emancipation_category(category_id)
    emancipation_categories << EmancipationCategory.find(category_id)
  end

  def add_emancipation_option(option_id)
    option_category = EmancipationOption.find(option_id).emancipation_category

    if !(option_category.mutually_exclusive && EmancipationOption.options_with_category_and_case(option_category, id).any?)
      emancipation_options << EmancipationOption.find(option_id)
    else
      raise "Attempted adding multiple options belonging to a mutually exclusive category"
    end
  end

  def clear_court_dates
    if next_court_date.nil?
      update(
        court_report_due_date: nil,
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
    birth_month_year_youth.nil? ? false : birth_month_year_youth <= 14.years.ago
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

  def has_hearing_type?
    hearing_type
  end

  def has_judge_name?
    judge_name
  end

  def has_transitioned?
    transition_aged_youth
  end

  def remove_emancipation_category(category_id)
    emancipation_categories.destroy(EmancipationCategory.find(category_id))
  end

  def remove_emancipation_option(option_id)
    emancipation_options.destroy(EmancipationOption.find(option_id))
  end

  def update_cleaning_contact_types(args)
    args = parse_date(errors, "court_report_due_date", args)

    return false unless errors.messages.empty?

    transaction do
      casa_case_contact_types.destroy_all
      update(args)
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

  def set_slug
    self.slug = case_number.parameterize preserve_case: true
  end

  def full_attributes_hash
    attributes.symbolize_keys.merge({contact_types: casa_case_contact_types.map(&:attributes), court_orders: case_court_orders.map(&:attributes)})
  end

  # def to_param
  #   id
  #   # slug # TODO use slug eventually for routes
  # end
end

# == Schema Information
#
# Table name: casa_cases
#
#  id                        :bigint           not null, primary key
#  active                    :boolean          default(TRUE), not null
#  birth_month_year_youth    :datetime
#  case_number               :string           not null
#  court_date                :datetime
#  court_report_due_date     :datetime
#  court_report_status       :integer          default("not_submitted")
#  court_report_submitted_at :datetime
#  slug                      :string
#  transition_aged_youth     :boolean          default(FALSE), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  casa_org_id               :bigint           not null
#  hearing_type_id           :bigint
#  judge_id                  :bigint
#
# Indexes
#
#  index_casa_cases_on_casa_org_id                  (casa_org_id)
#  index_casa_cases_on_case_number_and_casa_org_id  (case_number,casa_org_id) UNIQUE
#  index_casa_cases_on_hearing_type_id              (hearing_type_id)
#  index_casa_cases_on_judge_id                     (judge_id)
#  index_casa_cases_on_slug                         (slug)
#
# Foreign Keys
#
#  fk_rails_...  (casa_org_id => casa_orgs.id)
#
