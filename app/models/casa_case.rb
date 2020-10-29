class CasaCase < ApplicationRecord
  has_paper_trail

  has_many :case_assignments, dependent: :destroy
  has_many(:volunteers, through: :case_assignments, source: :volunteer, class_name: "User")
  has_many :case_contacts, dependent: :destroy
  has_many :past_court_dates, dependent: :destroy
  validates :case_number, uniqueness: {case_sensitive: false}, presence: true
  belongs_to :hearing_type, optional: true
  belongs_to :judge, optional: true
  belongs_to :casa_org

  has_many :casa_case_contact_types
  has_many :contact_types, through: :casa_case_contact_types, source: :contact_type
  accepts_nested_attributes_for :casa_case_contact_types

  scope :ordered, -> { order(updated_at: :desc) }
  scope :actively_assigned_to, ->(volunteer) {
    joins(:case_assignments).where(
      case_assignments: {volunteer: volunteer, is_active: true}
    )
  }
  scope :actively_assigned_excluding_volunteer, ->(volunteer) {
    joins(:case_assignments)
      .where(case_assignments: {is_active: true})
      .where.not(case_assignments: {volunteer: volunteer})
      .order(:case_number)
  }
  scope :not_assigned, ->(casa_org) {
    where(casa_org_id: casa_org.id)
      .left_outer_joins(:case_assignments)
      .where(case_assignments: {id: nil})
      .order(:case_number)
  }

  scope :should_transition, -> {
    where(transition_aged_youth: false)
      .where("birth_month_year_youth <= ?", 14.years.ago)
  }

  scope :due_date_passed, -> {
    where("court_date < ?", Time.now)
  }

  delegate :name, to: :hearing_type, prefix: true, allow_nil: true
  delegate :name, to: :judge, prefix: true, allow_nil: true

  def self.available_for_volunteer(volunteer)
    ids = connection.select_values(%{
      SELECT casa_cases.id
      FROM casa_cases
      WHERE id NOT IN (SELECT ca.casa_case_id
                      FROM case_assignments ca
                      WHERE ca.volunteer_id = #{volunteer.id}
                      GROUP BY ca.casa_case_id)
      GROUP BY casa_cases.id;
    })
    where(id: ids, casa_org: volunteer.casa_org)
      .order(:case_number)
  end

  def has_transitioned?
    transition_aged_youth
  end

  def update_cleaning_contact_types(args)
    args = parse_date("court_date", args)
    args = parse_date("court_report_due_date", args)

    return false unless errors.messages.empty?

    transaction do
      casa_case_contact_types.destroy_all
      update(args)
    end
  end

  def clear_court_dates
    update(court_date: nil,
           court_report_due_date: nil,
           court_report_submitted: false)
  end

  def deactivate
    update(active: false)
    case_assignments.map { |ca| ca.update(is_active: false) }
  end

  def reactivate
    update(active: true)
  end

  private

  def validate_date(day, month, year)
    raise Date::Error if day.blank? || month.blank? || year.blank?

    Date.parse("#{day}-#{month}-#{year}")
  end

  def parse_date(date_field_name, args)
    day = args.delete("#{date_field_name}(3i)")
    month = args.delete("#{date_field_name}(2i)")
    year = args.delete("#{date_field_name}(1i)")

    return args if day.blank? && month.blank? && year.blank?

    args[date_field_name.to_sym] = validate_date(day, month, year)
    args
  rescue Date::Error
    errors.messages[date_field_name.to_sym] << "was not a valid date."
    args
  end
end

# == Schema Information
#
# Table name: casa_cases
#
#  id                     :bigint           not null, primary key
#  active                 :boolean          default(TRUE), not null
#  birth_month_year_youth :datetime
#  case_number            :string           not null
#  court_date             :datetime
#  court_report_due_date  :datetime
#  court_report_submitted :boolean          default(FALSE), not null
#  transition_aged_youth  :boolean          default(FALSE), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  casa_org_id            :bigint           not null
#  hearing_type_id        :bigint
#  judge_id               :bigint
#
# Indexes
#
#  index_casa_cases_on_casa_org_id      (casa_org_id)
#  index_casa_cases_on_case_number      (case_number) UNIQUE
#  index_casa_cases_on_hearing_type_id  (hearing_type_id)
#  index_casa_cases_on_judge_id         (judge_id)
#
# Foreign Keys
#
#  fk_rails_...  (casa_org_id => casa_orgs.id)
#
