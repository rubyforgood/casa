require "rails_helper"

RSpec.describe ReportHelper do
  describe "#effective_date_parser" do
    context "when a date is informed" do
      let(:date) { DateTime.parse("01-01-2021") }
      it "returns date formated" do
        expect(helper.effective_date_parser(date)).to eq "January 01, 2021"
      end
    end
  end

  context "when no date is informed" do
    let(:date) { nil }

    it "returns current date formated" do
      expect(helper.effective_date_parser(date)).to eq DateTime.current.strftime(::DateHelper::RUBY_MONTH_DAY_YEAR_FORMAT)
    end
  end
end
