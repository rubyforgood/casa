require "rails_helper"

RSpec.describe DateHelper, type: :helper do
  describe "JQUERY_MONTH_DAY_YEAR_FORMAT" do
    it "is the jQuery datepicker month/day/year format" do
      expect(DateHelper::JQUERY_MONTH_DAY_YEAR_FORMAT).to eq("MM d, yyyy")
    end
  end

  describe "RUBY_MONTH_DAY_YEAR_FORMAT" do
    it "is the Ruby strftime month/day/year format" do
      expect(DateHelper::RUBY_MONTH_DAY_YEAR_FORMAT).to eq("%B %d, %Y")
    end
  end

  describe "#validate_date" do
    it "parses a valid day, month, and year" do
      expect(helper.validate_date("15", "6", "2021")).to eq(Date.new(2021, 6, 15))
    end

    it "raises Date::Error when the day is blank" do
      expect { helper.validate_date("", "6", "2021") }.to raise_error(Date::Error)
    end

    it "raises Date::Error when the month is blank" do
      expect { helper.validate_date("15", "", "2021") }.to raise_error(Date::Error)
    end

    it "raises Date::Error when the year is blank" do
      expect { helper.validate_date("15", "6", "") }.to raise_error(Date::Error)
    end
  end

  describe "#parse_date" do
    let(:errors) { ActiveModel::Errors.new(double("record")) }

    it "sets the parsed date under the field name when all parts are present" do
      args = {
        "court_report_due_date(1i)" => "2021",
        "court_report_due_date(2i)" => "6",
        "court_report_due_date(3i)" => "15"
      }

      result = helper.parse_date(errors, "court_report_due_date", args)

      expect(result[:court_report_due_date]).to eq(Date.new(2021, 6, 15))
      expect(result).not_to have_key("court_report_due_date(1i)")
      expect(errors).to be_empty
    end

    it "adds an error and leaves the date field unset when the date is invalid" do
      args = {
        "court_report_due_date(1i)" => "2021",
        "court_report_due_date(2i)" => "2",
        "court_report_due_date(3i)" => "31"
      }

      result = helper.parse_date(errors, "court_report_due_date", args)

      expect(result).not_to have_key(:court_report_due_date)
      expect(errors[:court_report_due_date]).to include("was not a valid date.")
    end

    it "strips the date part keys and adds no date when all parts are blank" do
      args = {
        "court_report_due_date(1i)" => "",
        "court_report_due_date(2i)" => "",
        "court_report_due_date(3i)" => "",
        "other_field" => "unchanged"
      }

      result = helper.parse_date(errors, "court_report_due_date", args)

      expect(result).to eq({"other_field" => "unchanged"})
      expect(errors).to be_empty
    end
  end
end
