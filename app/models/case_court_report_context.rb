# frozen_string_literal: true

require "date"

class CaseCourtReportContext
  attr_reader :report_path, :template, :date_range

  def initialize(args = {})
    @casa_case = CasaCase.friendly.find(args[:case_id])
    @volunteer = Volunteer.find(args[:volunteer_id]) if args[:volunteer_id]
    @time_zone = args[:time_zone]
    @path_to_template = args[:path_to_template]
    @court_date = args[:court_date] || @casa_case.next_court_date
    @case_court_orders = args[:case_court_orders] || @casa_case.case_court_orders
    @date_range = calculate_date_range(args)
  end

  def context
    {
      created_date: I18n.l(Time.current.in_time_zone(@time_zone).to_date, format: :full, default: nil),
      casa_case: case_details,
      case_contacts: case_contacts,
      case_court_orders: case_orders(@case_court_orders),
      case_mandates: case_orders(@case_court_orders), # backwards compatible with old Montgomery template - keep this! TODO test full generation
      latest_hearing_date: latest_hearing_date,
      org_address: org_address(@path_to_template),
      volunteer: volunteer_info,
      hearing_type_name: @court_date&.hearing_type&.name || "None"
    }
  end

  # @return [Array<Hash>]
  #   Each hash includes:
  #   - :name [String]
  #   - :type [String]
  #   - :dates [Array<String>]
  #   - :dates_by_medium_type [Array<String>]
  def case_contacts
    interviewees = filtered_interviewees
    return [] unless interviewees.size.positive?

    CaseContactsContactDates.new(interviewees).contact_dates_details
  end

  def latest_hearing_date
    latest_hearing_date = @casa_case.most_recent_past_court_date
    latest_hearing_date.nil? ? "___<LATEST HEARING DATE>____" : I18n.l(latest_hearing_date.date, format: :full, default: nil)
  end

  def case_orders(orders)
    orders.map do |case_order|
      {
        order: case_order.text,
        status: case_order.implementation_status&.humanize
      }
    end
  end

  def filtered_interviewees
    # this query is slow
    CaseContactContactType.includes(:case_contact, :contact_type)
      .where("case_contacts.casa_case_id": @casa_case.id)
      .where("case_contacts.occurred_at": @date_range)
  end

  def case_details
    {
      court_date: I18n.l(@court_date&.date, format: :full, default: nil),
      case_number: @casa_case.case_number,
      dob: I18n.l(@casa_case.birth_month_year_youth, format: :youth_date_of_birth, default: nil),
      is_transitioning: @casa_case.in_transition_age?,
      judge_name: @court_date&.judge&.name
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

  def org_address(path_to_template)
    is_default_template = path_to_template.end_with?("default_report_template.docx")
    @volunteer.casa_org.address if @volunteer && is_default_template
  end

  private

  def calculate_date_range(args)
    zone = args[:time_zone] ? ActiveSupport::TimeZone.new(args[:time_zone]) : Time.zone

    start_date = @casa_case.most_recent_past_court_date&.date&.in_time_zone(zone)
    start_date = zone.parse(args[:start_date]) if args[:start_date]&.present?

    end_date = args[:end_date]&.present? ? zone.parse(args[:end_date]) : nil

    start_date..end_date
  end
end
