# Builds an admin's org-wide landing dashboard: chapter-level stats plus the cases that
# need action (unassigned, or not contacted recently). Queries are aggregate/batched
# (active cases + one grouped contact lookup + count queries) so this stays cheap at org
# scale — do not reintroduce per-case/per-volunteer queries here.
class AdminDashboard
  FOLLOWUP_DAYS = Volunteer::CONTACT_MADE_IN_DAYS_NUM
  ATTENTION_LIMIT = 6

  def initialize(casa_org)
    @casa_org = casa_org
  end

  def active_cases
    @active_cases ||= @casa_org.casa_cases.active.order(:case_number).to_a
  end

  def unassigned_cases
    @unassigned_cases ||= active_cases.reject { |casa_case| assigned_case_ids.include?(casa_case.id) }
  end

  def cases_needing_contact
    @cases_needing_contact ||= active_cases.select do |casa_case|
      last = last_contacts[casa_case.id]
      last.nil? || (Date.current - last.to_date).to_i > FOLLOWUP_DAYS
    end
  end

  def needs_attention
    unassigned_cases.first(ATTENTION_LIMIT)
  end

  def empty?
    active_cases.empty? && active_volunteers.zero?
  end

  def stats
    {
      volunteers: active_volunteers,
      cases: active_cases.size,
      unassigned: unassigned_cases.size,
      needs_contact: cases_needing_contact.size
    }
  end

  private

  def active_volunteers
    @active_volunteers ||= Volunteer.in_organization(@casa_org).active.count
  end

  def assigned_case_ids
    @assigned_case_ids ||= CaseAssignment.active
      .where(casa_case_id: active_cases.map(&:id))
      .distinct
      .pluck(:casa_case_id)
      .to_set
  end

  def last_contacts
    @last_contacts ||= CaseContact
      .where(contact_made: true, casa_case_id: active_cases.map(&:id))
      .group(:casa_case_id)
      .maximum(:occurred_at)
  end
end
