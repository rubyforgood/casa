require "rails_helper"

RSpec.describe CourtReportValidator, type: :validator do
  let(:casa_case) { build(:casa_case) }

  # CasaCase#court_report_status= is a custom setter that auto-manages
  # court_report_submitted_at (nils it out for :not_submitted, defaults it
  # to Time.current otherwise - see app/models/casa_case.rb). Assigning
  # court_report_status keeps this order intentional: it must come first,
  # with court_report_submitted_at assigned after to land on the exact
  # combination each example below is testing.
  describe "mismatched status and submission date" do
    context "when submitted_at is nil and status is not not_submitted" do
      it "adds a status error" do
        casa_case.court_report_status = :in_review
        casa_case.court_report_submitted_at = nil

        described_class.new.validate(casa_case)

        expect(casa_case.errors[:court_report_status]).to include(
          "Court report submission date can't be nil if status is anything but not_submitted."
        )
      end
    end

    context "when submitted_at is present and status is not_submitted" do
      it "adds a submitted_at error" do
        casa_case.court_report_status = :not_submitted
        casa_case.court_report_submitted_at = DateTime.now

        described_class.new.validate(casa_case)

        expect(casa_case.errors[:court_report_submitted_at]).to include(
          "Submission date must be nil if court report status is not submitted."
        )
      end
    end
  end

  describe "matching status and submission date" do
    context "when status is not_submitted and submitted_at is nil" do
      it "adds no error" do
        casa_case.court_report_status = :not_submitted
        casa_case.court_report_submitted_at = nil

        described_class.new.validate(casa_case)

        expect(casa_case.errors[:court_report_status]).to be_empty
        expect(casa_case.errors[:court_report_submitted_at]).to be_empty
      end
    end

    context "when status is submitted and submitted_at is present" do
      it "adds no error" do
        casa_case.court_report_status = :submitted
        casa_case.court_report_submitted_at = DateTime.now

        described_class.new.validate(casa_case)

        expect(casa_case.errors[:court_report_status]).to be_empty
        expect(casa_case.errors[:court_report_submitted_at]).to be_empty
      end
    end
  end
end
