require "rails_helper"

RSpec.describe MileageRatesHelper, type: :helper do
  describe "#effective_date_parser" do
    context "with date" do
      let(:date) { DateTime.parse("01-01-2021") }

      it "returns date formated" do
        expect(helper.effective_date_parser(date)).to eq "January 01, 2021"
      end
    end
  end

  context "without date" do
    let(:date) { nil }

    it "returns current date formated" do
      expect(helper.effective_date_parser(date)).to eq DateTime.current.strftime(::DateHelper::RUBY_MONTH_DAY_YEAR_FORMAT)
    end
  end
end
