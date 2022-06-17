class MissingDataReport
  attr_reader :casa_cases

  def initialize(org_id)
    @casa_cases = CasaCase.where(casa_org_id: org_id)
      .includes(:court_dates, :case_court_orders)
  end

  def to_csv
    MissingDataExportCsvService.new(@casa_cases).perform
  end
end
