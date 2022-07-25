require "rails_helper"
require "csv"

RSpec.describe MissingDataReport, type: :model do
  describe "#to_csv" do
    let!(:casa_org) { create(:casa_org) }
    let(:result) { CSV.parse(described_class.new(casa_org.id).to_csv) }

    shared_examples "report_with_header" do
      it "contains header" do
        expect(result[0]).to eq([
          "Casa Case Number",
          "Youth Birth Month And Year",
          "Upcoming Hearing Date",
          "Court Orders"
        ])
      end
    end

    context "when there are casa cases" do
      let!(:incomplete_casa_cases) do
        [
          create(:casa_case),
          create(:casa_case, :with_one_court_order),
          create(:casa_case, :with_upcoming_court_date)
        ]
      end

      let!(:incomplete_casa_cases_from_other_org) { create_list(:casa_case, 3, casa_org: create(:casa_org)) }
      let!(:complete_casa_cases) { create_list(:casa_case, 3, :with_upcoming_court_date, :with_one_court_order) }

      let(:expected_result) do
        [
          [incomplete_casa_cases[0].case_number, "OK", "MISSING", "MISSING"],
          [incomplete_casa_cases[1].case_number, "OK", "MISSING", "OK"],
          [incomplete_casa_cases[2].case_number, "OK", "OK", "MISSING"]
        ]
      end

      it "includes only cases with missing data" do
        expect(result.length).to eq(4)
        expect(result).to include(*expected_result)
      end

      it_behaves_like "report_with_header"
    end

    context "when there are no casa cases" do
      it "includes only the header" do
        expect(result.length).to eq(1)
      end

      it_behaves_like "report_with_header"
    end
  end
end
