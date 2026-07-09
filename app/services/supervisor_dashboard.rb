# Builds the data for a supervisor's landing dashboard: the volunteers assigned to
# them, each volunteer's contact-follow-up status, and the summary stats up top.
#
# NOTE: runs a few queries per volunteer. Fine for a supervisor's assigned volunteers
# (typically a handful); revisit with a batched query (see VolunteerDatatable) if a
# supervisor ever carries a very large roster.
class SupervisorDashboard
  AVATAR_COLORS = %w[sky violet emerald amber rose teal indigo].freeze
  RECENT_CONTACT_DAYS = 60
  RECENT_HOURS_DAYS = 30

  Row = Struct.new(:volunteer, :cases_count, :status, :last_contact_on, :contacts_recent, :minutes_recent, keyword_init: true) do
    def needs_followup?
      status == :follow_up
    end

    def no_cases?
      status == :no_cases
    end

    def avatar_color
      AVATAR_COLORS[volunteer.id % AVATAR_COLORS.size]
    end

    def last_contact_label
      return "No contact logged" unless last_contact_on

      days = (Date.current - last_contact_on.to_date).to_i
      case days
      when 0 then "Today"
      when 1 then "Yesterday"
      else "#{days} days ago"
      end
    end

    def hours_label
      return "—" if minutes_recent.zero?

      hours, minutes = minutes_recent.divmod(60)
      [("#{hours}h" if hours.positive?), ("#{minutes}m" if minutes.positive?)].compact.join(" ")
    end
  end

  def initialize(supervisor)
    @supervisor = supervisor
  end

  def volunteers
    @volunteers ||= @supervisor.volunteers.to_a
  end

  def rows
    @rows ||= volunteers.map { |volunteer| build_row(volunteer) }
  end

  def needs_attention
    @needs_attention ||= rows.select(&:needs_followup?)
  end

  def stats
    {
      active: rows.size,
      needs_followup: needs_attention.size,
      no_cases: rows.count(&:no_cases?),
      hours_label: format_hours(rows.sum(&:minutes_recent))
    }
  end

  private

  def build_row(volunteer)
    cases_count = volunteer.actively_assigned_and_active_cases.size
    made = CaseContact.where(creator_id: volunteer.id, contact_made: true)

    Row.new(
      volunteer: volunteer,
      cases_count: cases_count,
      status: status_for(volunteer, cases_count),
      last_contact_on: made.maximum(:occurred_at),
      contacts_recent: made.where(occurred_at: RECENT_CONTACT_DAYS.days.ago.to_date..).count,
      minutes_recent: made.where(occurred_at: RECENT_HOURS_DAYS.days.ago.to_date..).sum(:duration_minutes).to_i
    )
  end

  def status_for(volunteer, cases_count)
    return :no_cases if cases_count.zero?

    volunteer.made_contact_with_all_cases_in_days? ? :on_track : :follow_up
  end

  def format_hours(minutes)
    return "0h" if minutes.zero?

    "#{(minutes / 60.0).round(1)}h"
  end
end
