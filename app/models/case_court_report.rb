# frozen_string_literal: true

require "date"
require "sablon"

class CaseCourtReport
  attr_reader :report_path, :context, :template

  DATE_FORMATS = {
    long_date: "%B %d, %Y",
    short_date: "%-m/%d",
    youth_dob: "%B %Y"
  }.freeze

  def initialize(args = {})
    @casa_case = CasaCase.find(args[:case_id])
    @volunteer = Volunteer.find(args[:volunteer_id])

    @context = prepare_context
    @template = Sablon.template(args[:path_to_template])

    # optional
    @report_path = args[:path_to_report]
  end

  def generate!
    @template.render_to_file(@report_path, @context)
  end

  def generate_to_string
    @template.render_to_string(@context)
  end

  private

  def prepare_context
    {
      created_date: Date.today.strftime(DATE_FORMATS[:long_date]),
      casa_case: prepare_case_details,
      case_contacts: prepare_case_contacts,
      volunteer: {
        name: @volunteer.display_name,
        supervisor_name: @volunteer.supervisor.display_name,
        assignment_date: @casa_case.case_assignments.find_by(volunteer: @volunteer).created_at&.strftime(DATE_FORMATS[:long_date])
      }
    }
  end

  def format_date_contact_attempt(case_contact)
    case_contact.occurred_at.strftime(DATE_FORMATS[:short_date])
      .concat(case_contact.contact_made ? "" : "*")
  end

  def prepare_case_contacts
    interviewees = CaseContactContactType.includes(:case_contact, :contact_type).where("case_contacts.casa_case_id": @casa_case.id)
    interviewees = interviewees.where("occurred_at > ?", @casa_case.court_date) if @casa_case.court_date

    return [] unless interviewees.size.positive?

    contact_dates_as_hash = aggregate_contact_dates(interviewees)
    contact_dates_as_hash.map do |type, dates|
      {
        name: "Firstname Lastname",
        type: type,
        dates: dates.join(", ")
      }
    end
  end

  def aggregate_contact_dates(people)
    contact_dates = Hash.new([])

    people.each do |person|
      contact_type = person.contact_type.name
      date_with_format = format_date_contact_attempt(person.case_contact)

      contact_dates[contact_type] << (date_with_format) && next if contact_dates.key?(contact_type)

      contact_dates[contact_type] = [date_with_format]
    end

    contact_dates
  end

  def prepare_case_details
    {
      court_date: @casa_case.court_date&.strftime(DATE_FORMATS[:long_date]),
      case_number: @casa_case.case_number,
      dob: @casa_case.birth_month_year_youth&.strftime(DATE_FORMATS[:youth_dob])
    }
  end
end
