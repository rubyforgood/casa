require "rails_helper"

RSpec.describe CasaCaseDecorator do
  describe "#court_report_submission" do
    subject { casa_case.decorate.court_report_submission }
    let(:casa_case) { build(:casa_case, court_report_status: court_report_status) }

    context "when case_report_status is not_submitted" do
      let(:court_report_status) { :not_submitted }

      it { is_expected.to eq("Not submitted") }
    end

    context "when case_report_status is submitted" do
      let(:court_report_status) { :submitted }

      it { is_expected.to eq("Submitted") }
    end

    context "when case_report_status is in_review" do
      let(:court_report_status) { :in_review }

      it { is_expected.to eq("In review") }
    end

    context "when case_report_status is completed" do
      let(:court_report_status) { :completed }

      it { is_expected.to eq("Completed") }
    end
  end

  describe "#court_report_submission" do
    subject { casa_case.decorate.court_report_submitted_date }
    let(:submitted_time) { Time.parse("Sun Nov 08 11:06:20 2020") }
    let(:casa_case) { build(:casa_case, court_report_submitted_at: submitted_time) }

    it { is_expected.to eq "November 8, 2020" }

    context "when report is not submitted" do
      let(:submitted_time) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe "#formatted_updated_at" do
    subject { casa_case.decorate.formatted_updated_at }
    let(:updated_at_time) { Time.parse("Wed Dec 9 12:51:20 2020") }
    let(:casa_case) { build(:casa_case, updated_at: updated_at_time) }

    it { is_expected.to eq "12-09-2020" }
  end

  describe "#transition_age_youth" do
    it "returns transition age youth status with icon if over 14 years old" do
      casa_case = build(:casa_case, birth_month_year_youth: 14.years.ago)
      expect(casa_case.decorate.transition_aged_youth)
        .to eq "Yes #{CasaCase::TRANSITION_AGE_YOUTH_ICON}"
    end

    it "returns non-transition age youth status with icon if not over 14 years old" do
      casa_case = build(:casa_case, birth_month_year_youth: 13.years.ago)
      expect(casa_case.decorate.transition_aged_youth)
        .to eq "No #{CasaCase::NON_TRANSITION_AGE_YOUTH_ICON}"
    end
  end

  describe "#transition_age_youth_icon" do
    it "returns transition age youth icon if over 14 years old" do
      casa_case = build(:casa_case, birth_month_year_youth: 14.years.ago)
      expect(casa_case.decorate.transition_aged_youth_icon)
        .to eq CasaCase::TRANSITION_AGE_YOUTH_ICON
    end

    it "returns non-transition age youth icon if not over 14 years old" do
      casa_case = build(:casa_case, birth_month_year_youth: 13.years.ago)
      expect(casa_case.decorate.transition_aged_youth_icon)
        .to eq CasaCase::NON_TRANSITION_AGE_YOUTH_ICON
    end
  end
end
