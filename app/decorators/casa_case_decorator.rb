class CasaCaseDecorator < Draper::Decorator
  include ActionView::Helpers::DateHelper

  delegate_all

  def case_contacts_ordered_by_occurred_at
    object.case_contacts.order(occurred_at: :desc)
  end

  def case_contacts_latest
    object.case_contacts.order(occurred_at: :desc, created_at: :desc).first
  end

  def case_contacts_latest_before(date)
    object.case_contacts.where("occurred_at < ?", date).max_by(&:occurred_at)
  end

  def case_contacts_filtered_by_active_assignment_ordered_by_occurred_at
    object.case_contacts
      .joins("INNER JOIN case_assignments on case_assignments.casa_case_id = case_contacts.casa_case_id and case_assignments.volunteer_id = case_contacts.creator_id")
      .where("case_assignments.hide_old_contacts = false")
      .order(occurred_at: :desc)
  end

  def court_report_submission
    object.court_report_status.humanize
  end

  def court_report_submitted_date
    I18n.l(object.court_report_submitted_at, format: :full, default: nil)
  end

  def court_report_select_option
    volunteer_names = object.assigned_volunteers.map(&:display_name).join(",")

    [
      "#{object.case_number} - #{object.in_transition_age? ? "transition" : "non-transition"}(assigned to #{(volunteer_names.length > 0) ? volunteer_names : "no one"})",
      object.case_number,
      {
        "data-transitioned": object.in_transition_age?,
        "data-lookup": volunteer_names
      }
    ]
  end

  def date_in_care
    return nil unless object.date_in_care
    I18n.l(object.date_in_care, format: :youth_date_of_birth)
  end

  def duration_in_care
    return nil unless object.date_in_care
    "(#{time_ago_in_words(object.date_in_care)} ago)"
  end

  def calendar_next_court_date
    return nil unless object.next_court_date
    {start: calendar_format(object.next_court_date.date), end: calendar_format(object.next_court_date.date + 1.day)}
  end

  def calendar_court_report_due_date
    return nil unless object.court_report_due_date
    {start: calendar_format(object.court_report_due_date), end: calendar_format(object.court_report_due_date + 1.day)}
  end

  def calendar_format(date)
    I18n.l(date, format: :long, default: "")
  end

  def formatted_updated_at
    I18n.l(object.updated_at, format: :standard, default: nil)
  end

  def inactive_class
    (!object.active) ? "table-secondary" : ""
  end

  def status
    object.active ? "Active" : "Inactive"
  end

  def successful_contacts_this_week
    this_week = Date.today - 7.days..Date.today
    object.case_contacts.where(occurred_at: this_week).where(contact_made: true).count
  end

  def successful_contacts_this_week_before(date)
    this_week_before_date = Date.today - 7.days..date
    object.case_contacts.where(occurred_at: this_week_before_date).where(contact_made: true).count
  end

  def transition_aged_youth
    object.in_transition_age? ? "Yes #{CasaCase::TRANSITION_AGE_YOUTH_ICON}" : "No #{CasaCase::NON_TRANSITION_AGE_YOUTH_ICON}"
  end

  def transition_aged_youth_icon
    object.in_transition_age? ? CasaCase::TRANSITION_AGE_YOUTH_ICON : CasaCase::NON_TRANSITION_AGE_YOUTH_ICON
  end

  def unsuccessful_contacts_this_week
    this_week = Date.today - 7.days..Date.today
    object.case_contacts.where(occurred_at: this_week).where(contact_made: false).count
  end

  def unsuccessful_contacts_this_week_before(date)
    this_week_before_date = Date.today - 7.days..date
    object.case_contacts.where(occurred_at: this_week_before_date).where(contact_made: false).count
  end

  def emancipation_checklist_count
    "#{object.casa_case_emancipation_categories.count} / #{EmancipationCategory.count}"
  end

  def show_contact_type?(contact_type_id)
    object.casa_case_contact_types.map(&:contact_type_id).include?(contact_type_id)
  end
end
