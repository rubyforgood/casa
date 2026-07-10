# Builds a volunteer's landing dashboard: their actively-assigned active cases, each
# case's contact-follow-up status, and the summary stats up top. Per-case last-contact
# lookups are batched into one query, so this is safe for a volunteer's roster of cases.
class VolunteerDashboard
  RECENT_HOURS_DAYS = 30

  Row = Struct.new(:casa_case, :last_contact_on, keyword_init: true) do
    def needs_contact?
      last_contact_on.nil? || (Date.current - last_contact_on.to_date).to_i > Volunteer::CONTACT_MADE_IN_DAYS_NUM
    end

    def status
      needs_contact? ? :needs_contact : :on_track
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
  end

  def initialize(volunteer)
    @volunteer = volunteer
  end

  def cases
    @cases ||= @volunteer.actively_assigned_and_active_cases.to_a
  end

  def rows
    @rows ||= cases
      .map { |casa_case| Row.new(casa_case: casa_case, last_contact_on: last_contacts[casa_case.id]) }
      .sort_by { |row| [row.needs_contact? ? 0 : 1, row.last_contact_on || Date.new(0)] }
  end

  def needs_attention
    @needs_attention ||= rows.select(&:needs_contact?)
  end

  def stats
    {
      cases: rows.size,
      needs_contact: needs_attention.size,
      hours_label: @volunteer.hours_spent_in_days(RECENT_HOURS_DAYS).presence || "0h"
    }
  end

  private

  def last_contacts
    @last_contacts ||= CaseContact
      .where(creator_id: @volunteer.id, contact_made: true, casa_case_id: cases.map(&:id))
      .group(:casa_case_id)
      .maximum(:occurred_at)
  end
end
