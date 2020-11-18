require "rails_helper"
require_relative "../../scripts/import_casa_case_date_of_birth"

RSpec.describe "ImportCasaCaseDateOfBirth" do
  data = "
    1/21/2000,,,,CINA 11-1234,
    2/22/2000,,,,TPR 12-1234,
    3/3/2000,,,,CINA 13-1234,
    "

  it "returns not found" do
    # def update_casa_case_dates_of_birth(data, case_not_found, already_has_nonmatching_date, no_edit_made)
    case_not_found = []
    already_has_nonmatching_date = []
    no_edit_made = []
    create(:casa_org, name: "Prince George CASA")
    result = update_casa_case_dates_of_birth(data, case_not_found, already_has_nonmatching_date, no_edit_made, [])
    expect(result).to eq({nonmatching: [], not_found: ["CINA 11-1234", "TPR 12-1234", "CINA 13-1234"], no_edit_made: []})
    expect(case_not_found).to eq(["CINA 11-1234", "TPR 12-1234", "CINA 13-1234"])
    expect(already_has_nonmatching_date).to eq([])
    expect(no_edit_made).to eq([])
  end

  xit "returns not found" do
    casa_org = create(:casa_org, name: "Prince George CASA")
    create(:casa_case, casa_org: casa_org, case_number: "CINA 11-1234", birth_month_year_youth: nil)
    create(:casa_case, casa_org: casa_org, case_number: "TPR 12-1234", birth_month_year_youth: Date.new(2000, 2, 22)) # matching date
    create(:casa_case, casa_org: casa_org, case_number: "CINA 13-1234", birth_month_year_youth: Date.new(2000, 9, 1)) # NON-matching date
    create(:casa_case, casa_org: casa_org, case_number: "CINA 14-8888")
    create(:casa_case, case_number: "CINA 15-9999") # different casa org
    case_not_found = []
    already_has_nonmatching_date = []
    no_edit_made = []
    result = update_casa_case_dates_of_birth(data, case_not_found, already_has_nonmatching_date, no_edit_made, [])
    expect(result).to eq(
      nonmatching: [
        {
          case_number: "CINA 13-1234",
          import_date: DateTime.new(2000, 3, 3),
          prev_date: DateTime.new(2000, 9, 1)
        }
      ],
      not_found: [],
      no_edit_made: ["TPR 12-1234"]
    )
    expect(case_not_found).to eq([])
    expect(already_has_nonmatching_date).to eq([{
      case_number: "CINA 13-1234",
      import_date: Date.new(2000, 3, 3),
      prev_date: Date.new(2000, 9, 1)
    }])
    expect(no_edit_made).to eq(["TPR 12-1234"])
  end
end
