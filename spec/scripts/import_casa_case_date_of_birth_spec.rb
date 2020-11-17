require "rails_helper"
require_relative "../../scripts/import_casa_case_date_of_birth"

RSpec.describe "ImportCasaCaseDateOfBirth" do
  data = "" "
    1/21/2000,,,,CINA 11-1234,
    2/22/2000,,,,TPR 12-1234,
    3/3/2000,,,,CINA 13-1234,
    " ""
  it "returns not found" do
    result = update_casa_case_dates_of_birth(data)
    expect(result).to eq({nonmatching: [], not_found: ["CINA 11-1234", "TPR 12-1234", "CINA 13-1234"]})
  end

  it "returns not found" do
    create(:casa_case, case_number: "CINA 11-1234", birth_month_year_youth: nil)
    cc2 = create(:casa_case, case_number: "TPR 12-1234", birth_month_year_youth: Date.new(2000, 2, 22)) # matching date
    cc3 = create(:casa_case, case_number: "CINA 13-1234", birth_month_year_youth: Date.new(2000, 9, 1)) # NON-matching date
    create(:casa_case, case_number: "CINA 13-9999")
    result = update_casa_case_dates_of_birth(data)
    expect(result).to eq(
      nonmatching: [
        {
          cc_id: cc2.id,
          import_date: Date.new(2000, 2, 22),
          prev_date: Date.new(2000, 2, 22)
        }, {
          cc_id: cc3.id,
          import_date: Date.new(2000, 3, 3),
          prev_date: Date.new(2000, 9, 1)
        }
      ],
      not_found: []
    )
  end
end
