require "rails_helper"

RSpec.describe MissingDataExportCsvService do
  let!(:casa_cases) { create_list(:casa_case, 3) }
  let(:result) { described_class.new(CasaCase.all).perform }

  describe "#perform" do
    it "returns a string formatted as csv" do
      expect(result).to match("Casa Case Number,Youth Birth Month And Year,Upcoming Hearing Date,Court Orders\n")
      expect(result).to match("#{casa_cases[0].case_number},OK,MISSING,MISSING\n")
      expect(result).to match("#{casa_cases[1].case_number},OK,MISSING,MISSING\n")
      expect(result).to match("#{casa_cases[2].case_number},OK,MISSING,MISSING\n")
    end
  end
end
