require "rails_helper"

RSpec.describe CourtDateDecorator, type: :decorator do
  let(:casa_org) { build(:casa_org) }
  let(:casa_case) { build(:casa_case, casa_org: casa_org) }
  let(:court_date) { build(:court_date, casa_case: casa_case, date: date, hearing_type: hearing_type) }
  let(:date) { Time.zone.local(2024, 1, 9, 14, 30) }
  let(:hearing_type) { build(:hearing_type, casa_org: casa_org, name: "Scheduling conference") }

  around do |example|
    I18n.with_locale(:en) { example.run }
  end

  describe "#formatted_date" do
    subject(:formatted_date) { court_date.decorate.formatted_date }

    it "formats the date without the time using the full date format" do
      expect(formatted_date).to eq("January 9, 2024")
    end

    context "when the date is missing" do
      let(:date) { nil }

      it "returns nil" do
        expect(formatted_date).to be_nil
      end
    end
  end

  describe "#court_date_info" do
    subject(:court_date_info) { court_date.decorate.court_date_info }

    it "separates the formatted date and hearing name with a hyphen" do
      expect(court_date_info).to eq("January 9, 2024 - Scheduling conference")
    end

    context "when the hearing type is missing" do
      let(:hearing_type) { nil }

      it "returns only the formatted date" do
        expect(court_date_info).to eq("January 9, 2024")
      end
    end

    context "when the date is missing" do
      let(:date) { nil }

      it "returns only the hearing name" do
        expect(court_date_info).to eq("Scheduling conference")
      end

      context "when the hearing type is also missing" do
        let(:hearing_type) { nil }

        it "returns an empty string" do
          expect(court_date_info).to eq("")
        end
      end
    end
  end
end
