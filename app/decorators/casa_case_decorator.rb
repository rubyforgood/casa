class CasaCaseDecorator < Draper::Decorator
  delegate_all

  def case_contacts_ordered_by_occurred_at
    object.case_contacts.order(occurred_at: :desc)
  end

  def case_contacts_latest
    object.case_contacts.max_by(&:occurred_at)
  end

  def case_contacts_latest_before(date)
    object.case_contacts.where("occurred_at < ?", date).max_by(&:occurred_at)
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
      "#{object.case_number} (assigned to #{volunteer_names.length > 0 ? volunteer_names : "no one"})",
      object.case_number,
      {
        "data-lookup": volunteer_names
      }
    ]
  end

  def court_mandate_select_options
    CaseCourtMandate.implementation_statuses.map do |status|
      [status[0].humanize, status[0]]
    end
  end

  def formatted_updated_at
    I18n.l(object.updated_at, format: :standard, default: nil)
  end

  def inactive_class
    !object.active ? "table-secondary" : ""
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
