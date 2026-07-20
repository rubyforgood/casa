# Computes activity metrics -- case-contact volume, monthly active users, and a
# contact-timing heatmap -- either for the whole platform (default) or for a single
# CasaOrg when one is passed in. Extracted from HealthController so the all-CASA
# "Metrics" console and the per-chapter "Analytics" page share identical chart math.
#
#   MetricsReport.new                       # platform-wide (all-CASA Metrics)
#   MetricsReport.new(casa_org: current_org) # scoped to one chapter (Analytics)
class MetricsReport
  ALLOWED_RANGES = [3, 6, 12].freeze
  DEFAULT_RANGE = 12

  # Clamp a user-supplied ?range= to one of the allowed presets (default 12 months).
  def self.clamp_range(value)
    ALLOWED_RANGES.include?(value.to_i) ? value.to_i : DEFAULT_RANGE
  end

  def initialize(casa_org: nil)
    @casa_org = casa_org
  end

  def monthly_case_contacts(months_back)
    months = last_month_starts(months_back)
    pick = ->(counts) { months.map { |m| counts.find { |k, _| k.year == m.year && k.month == m.month }&.last || 0 } }
    total = case_contacts.group_by_month(:created_at, last: months_back).count
    with_notes = case_contacts.where.not(notes: [nil, ""]).group_by_month(:created_at, last: months_back).count
    loggers = case_contacts.group_by_month(:created_at, last: months_back).distinct.count(:creator_id)
    {
      labels: months.map { |m| m.strftime("%b") },
      series: [
        {name: "Total contacts", data: pick.call(total)},
        {name: "With notes", data: pick.call(with_notes)},
        {name: "Unique loggers", data: pick.call(loggers)}
      ],
      distinct_loggers: case_contacts.where(created_at: months.first..).distinct.count(:creator_id)
    }
  end

  def monthly_active_users(months_back)
    months = last_month_starts(months_back)
    keys = months.map { |m| m.strftime("%b %Y") }
    volunteers = active_users_by_type("Volunteer")
    supervisors = active_users_by_type("Supervisor")
    admins = active_users_by_type("CasaAdmin")
    logged = case_contacts.joins(supervisor_volunteer: :volunteer).group_by_month(:created_at, format: "%b %Y").distinct.count(:creator_id)
    {
      labels: months.map { |m| m.strftime("%b") },
      series: [
        {name: "Volunteers", data: keys.map { |k| volunteers[k] || 0 }},
        {name: "Supervisors", data: keys.map { |k| supervisors[k] || 0 }},
        {name: "Admins", data: keys.map { |k| admins[k] || 0 }},
        {name: "Active loggers", data: keys.map { |k| logged[k] || 0 }}
      ]
    }
  end

  def contact_creation_heatmap(months_back)
    grid = case_contacts.where(created_at: months_back.months.ago.beginning_of_month..)
      .group("EXTRACT(DOW FROM case_contacts.created_at)::int")
      .group("EXTRACT(HOUR FROM case_contacts.created_at)::int").count
    {grid: grid, max: grid.values.max || 0}
  end

  private

  attr_reader :casa_org

  # CaseContact has no casa_org_id of its own; it reaches an org through its casa_case,
  # so we use the model's dedicated `casa_org` scope (joins casa_cases) rather than the
  # generic ByOrganizationScope. Global default is every contact.
  def case_contacts
    casa_org ? CaseContact.casa_org(casa_org.id) : CaseContact.all
  end

  # Distinct signed-in users of a given STI type per month. LoginActivity has no org of
  # its own either, so we reach it through the joined users row (users.casa_org_id).
  def active_users_by_type(type)
    rel = LoginActivity
      .joins("INNER JOIN users ON users.id = login_activities.user_id AND login_activities.user_type = 'User'")
      .where(users: {type: type}, success: true)
    rel = rel.where(users: {casa_org_id: casa_org.id}) if casa_org
    rel.group_by_month(:created_at, format: "%b %Y").distinct.count(:user_id)
  end

  def last_month_starts(months_back)
    (0..months_back - 1).map { |i| (months_back - 1 - i).months.ago.beginning_of_month }
  end
end
