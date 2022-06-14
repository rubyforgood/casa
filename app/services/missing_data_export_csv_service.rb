require "csv"

class MissingDataExportCsvService
  attr_reader :casa_cases

  def initialize(casa_cases)
    @casa_cases = casa_cases
  end

  def perform
    CSV.generate(headers: true) do |csv|
      csv << full_data.keys.map(&:to_s).map(&:titleize)
      if casa_cases.present?
        casa_cases.decorate.each do |casa_case|
          if has_missing_values?(casa_case)
            csv << full_data(casa_case).values
          end
        end
      end
    end
  end

  private

  def has_missing_values?(casa_case)
    !casa_case.birth_month_year_youth? ||
      casa_case.next_court_date.nil? ||
      casa_case.case_court_orders.empty?
  end

  def get_status(missing)
    missing ? "MISSING" : "OK"
  end

  def full_data(casa_case = nil)
    {
      casa_case_number: casa_case&.case_number,
      youth_birth_month_and_year: get_status(!casa_case&.birth_month_year_youth?),
      upcoming_hearing_date: get_status(casa_case&.next_court_date.nil?),
      court_orders: get_status(casa_case&.case_court_orders&.empty?)
    }
  end
end
