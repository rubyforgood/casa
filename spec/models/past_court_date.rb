require "rails_helper"

RSpec.describe PastCourtDate, type: :model do
  describe "validations" do
    it { is_expected.to belong_to(:casa_case) }
    it { is_expected.to belong_to(:hearing_type).optional(true) }
    it { is_expected.to belong_to(:judge).optional(true) }
  end

  describe "methods" do
    let(:past_court_date) { build_stubbed(:past_court_date) }

    pending "#associated_reports"
    pending "#latest_associated_report"

    describe "#additional_info?" do
      subject(:additional_info?) { past_court_date.additional_info? }

      context "without court details" do
        it { is_expected.to be_falsy }
      end

      context "with court details" do
        context "with judge" do
          before { past_court_date.judge = build_stubbed(:judge) }

          it { is_expected.to be_truthy }
        end

        context "with hearing type" do
          before { past_court_date.hearing_type = build_stubbed(:hearing_type) }

          it { is_expected.to be_truthy }
        end

        context "with both judge and hearing type" do
          before do
            past_court_date.judge = build_stubbed(:judge)
            past_court_date.hearing_type = build_stubbed(:hearing_type)
          end

          it { is_expected.to be_truthy }
        end
      end
    end

    describe "#generate_report" do
      subject(:generate_report) { past_court_date.generate_report }

      it { is_expected.not_to be_nil }
    end

    describe "#display_name" do
      subject(:display_name) { past_court_date.display_name }

      let(:casa_case) { build_stubbed(:casa_case, case_number: "CINA-000") }
      let(:past_court_date) { build_stubbed(:past_court_date, casa_case: casa_case, date: Time.zone.local(2020, 5, 3)) }

      it { is_expected.to eq "CINA-000 - Past Court Date - 2020-05-03" }
    end
  end

  it "has a valid factory" do
    past_court_date = build(:past_court_date)
    expect(past_court_date.valid?).to be_truthy
  end
end
