require "csv"

class VolunteersEmailsExportCsvService
  attr_reader :volunteers

  def initialize
    @volunteers = Volunteer.active
  end

  def perform
    CSV.generate(headers: true) do |csv|
      csv << full_data.keys.map(&:to_s).map(&:titleize)
      @volunteers.each do |volunteer|
        csv << full_data(volunteer).values
      end
    end
  end

  private

  def full_data(volunteer = nil)
    {
      email: volunteer&.email,
      case_number: volunteer&.casa_cases&.active&.pluck(:case_number).to_a.join(", "),
      volunteer_name: volunteer&.display_name,
      case_transition_aged_status: volunteer&.casa_cases&.active&.pluck(:transition_aged_youth).to_a.join(", ")
    }
  end
end
