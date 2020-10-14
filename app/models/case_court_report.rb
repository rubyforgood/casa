# frozen_string_literal: true

require "date"
require "sablon"

class CaseCourtReport
  attr_reader :report_path

  def initialize(args = {})
    @casa_case      = CasaCase.find(args[:case_id])
    @volunteer      = Volunteer.find(args[:volunteer_id])
    @template_path  = args[:path_to_template]
    @report_path    = args[:path_to_report]
  end

  def generate!
    context = {
      created_date: format_long_date(Date.today),
      casa_case: prepare_case_details,
      case_contacts: prepare_case_contacts,
      volunteer: {
        name: @volunteer.display_name,
        supervisor_name: @volunteer.supervisor.display_name
      }
    }

    Sablon.template(@template_path).render_to_file(@report_path, context)
  end

  private

  def format_long_date(date)
    date.strftime("%B %d, %Y")
  end

  def format_short_date(date)
    date.strftime("%-m/%d")
  end

  def format_date_contact_attempt(case_contact)
    format_short_date(case_contact.occurred_at)
      .concat(case_contact.contact_made ? "" : "*")
  end

  def prepare_case_contacts
    interviewees = CaseContactContactType.includes(:case_contact, :contact_type).where("case_contacts.casa_case_id": @casa_case.id)
    interviewees = interviewees.where("occurred_at > ?", @casa_case.court_date) if @casa_case.court_date

    contact_dates = aggregate_contact_dates(interviewees)

    contact_dates.map do |type, dates|
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

      contact_dates[contact_type] << date_with_format and next if contact_dates.key?(contact_type)

      contact_dates[contact_type] = [date_with_format]
    end

    contact_dates
  end

  def prepare_case_details
    {
      court_date: @casa_case.court_date,
      case_number: @casa_case.case_number,
      dob: @casa_case.birth_month_year_youth,
      assignment_date: format_long_date(@volunteer.case_assignments.find_by(casa_case: @casa_case).created_at)
    }
  end
end
