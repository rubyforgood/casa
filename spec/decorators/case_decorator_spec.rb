require "rails_helper"

RSpec.describe CasaCaseDecorator do
  describe "#court_report_submission" do
    context "when case_report_submitted is false" do
      it "returns Not Submitted" do
        casa_case = create(:casa_case)

        expect(casa_case.decorate.court_report_submission).to eq "Not Submitted"
      end
    end

    context "when duration_minutes is greater than 60" do
      it "when court_report_submitted is true" do
        casa_case = create(:casa_case)
        casa_case.court_report_submitted = true

        expect(casa_case.decorate.court_report_submission).to eq "Submitted"
      end
    end
  end
end
