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
end
