# frozen_string_literal: true

require "date"
require "sablon"

class CaseCourtReport
  attr_reader :report_path, :context, :template

  def initialize(args = {})
    @casa_case = CasaCase.find(args[:case_id])
    @volunteer = Volunteer.find(args[:volunteer_id]) if args[:volunteer_id]

    @context = prepare_context(args[:path_to_template].end_with?("default_report_template.docx"))
    @template = Sablon.template(args[:path_to_template])
  end

  def generate_to_string
    @template.render_to_string(@context)
  end

  private

  def prepare_context(is_default_template)
    latest_hearing_date = @casa_case.latest_past_court_date

    {
      created_date: I18n.l(Date.today, format: :full, default: nil),
      casa_case: prepare_case_details,
      case_contacts: prepare_case_contacts,
      case_mandates: prepare_case_mandates,
      latest_hearing_date: latest_hearing_date.nil? ? "___<LATEST HEARING DATE>____" : I18n.l(latest_hearing_date.date, format: :full, default: nil),
      org_address: org_address(is_default_template),
      volunteer: volunteer_info
    }
  end

  def prepare_case_contacts
    cccts = CaseContactContactType.includes(:case_contact, :contact_type).where("case_contacts.casa_case_id": @casa_case.id)
    interviewees = filter_out_old_case_contacts(cccts)
    return [] unless interviewees.size.positive?

    CaseContactsContactDates.new(interviewees).contact_dates_details
  end

  def prepare_case_mandates
    case_mandate_data = []

    @casa_case.case_court_mandates.each do |case_mandate|
      case_mandate_data << {
        order: case_mandate.mandate_text,
        status: case_mandate.implementation_status&.humanize
      }
    end

    case_mandate_data
  end

  def filter_out_old_case_contacts(interviewees)
    most_recent_court_date = @casa_case.past_court_dates.order(:date).last&.date
    if most_recent_court_date
      interviewees.where("occurred_at > ?", most_recent_court_date)
    else
      interviewees
    end
  end

  def prepare_case_details
    {
      court_date: I18n.l(@casa_case.court_date, format: :full, default: nil),
      case_number: @casa_case.case_number,
      dob: I18n.l(@casa_case.birth_month_year_youth, format: :youth_date_of_birth, default: nil),
      is_transitioning: @casa_case.in_transition_age?
    }
  end

  def volunteer_info
    if @volunteer
      {
        name: @volunteer.display_name,
        supervisor_name: @volunteer.supervisor&.display_name || "",
        assignment_date: I18n.l(@casa_case.case_assignments.find_by(volunteer: @volunteer).created_at, format: :full, default: nil)
      }
    end
  end

  def org_address(is_default_template)
    @volunteer.casa_org.address if @volunteer && is_default_template
  end
end
