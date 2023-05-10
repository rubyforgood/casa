require "csv"

class VolunteersEmailsExportCsvService
  attr_reader :volunteers

  def initialize(casa_org)
    @volunteers = Volunteer.active.in_organization(casa_org)
  end

  def call
    CSV.generate(headers: true) do |csv|
      csv << full_data.keys.map(&:to_s).map(&:titleize)
      @volunteers.each do |volunteer|
        csv << full_data(volunteer).values
      end
    end
  end

  private

  def full_data(volunteer = nil)
    active_casa_cases = volunteer&.casa_cases&.active&.map { |c| [c.case_number, c.in_transition_age?] }.to_h
    old_emails = volunteer&.old_emails? ? volunteer.old_emails.join(", ") : "None"
    {
      email: volunteer&.email,
      old_emails: old_emails,
      case_number: active_casa_cases.keys.join(", "),
      volunteer_name: volunteer&.display_name,
      case_transition_aged_status: active_casa_cases.values.join(", ")
    }
  end
end
