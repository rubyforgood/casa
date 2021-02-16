require "rails_helper"

RSpec.describe SupervisorMailer, :type => :mailer do
  describe ".weekly_digest" do
    let(:supervisor) { build(:supervisor) }
    let(:volunteer) { build(:volunteer, casa_org: supervisor.casa_org, supervisor: supervisor) }
    
    let(:mail) { SupervisorMailer.weekly_digest(supervisor) }

    context "when a supervisor has volunteer assigned to a casa case" do
      let!(:case_assignment) { create(:case_assignment, casa_case: build(:casa_case, casa_org: supervisor.casa_org), volunteer: volunteer) }
      it "shows a summary for a volunteer assigned to the supervisor" do
        expect(mail.body.encoded).to match("Summary for #{ volunteer.display_name }")
      end

      it "does not show a case contact that did not occurr in the week" do
      end

      it "shows the latest case contact that occurred in the week" do
      end
    end

    context "when a supervisor has a volunteer who is unassigned from a casa case during the week" do
      it "shows a summary for a volunteer recently unassigned from the supervisor" do
      end

      it "does not show a case contact that occurred past the unassignment date in the week" do
      end

      it "shows the latest case contact that occurred in the week before the unassignment date" do
      end
    end

    it "does not show a summary for a volunteer unassigned from the supervisor before the week" do
    end
  end
end
