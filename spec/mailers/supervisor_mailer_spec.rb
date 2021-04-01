require "rails_helper"

RSpec.describe SupervisorMailer, type: :mailer do
  describe ".weekly_digest" do
    let(:supervisor) { build(:supervisor) }
    let(:volunteer) { build(:volunteer, casa_org: supervisor.casa_org, supervisor: supervisor) }
    let(:casa_case) { build(:casa_case, casa_org: supervisor.casa_org) }

    let(:mail) { SupervisorMailer.weekly_digest(supervisor) }

    context "when a supervisor has volunteer assigned to a casa case" do
      let!(:case_assignment) { create(:case_assignment, casa_case: casa_case, volunteer: volunteer) }

      it "shows a summary for a volunteer assigned to the supervisor" do
        expect(mail.body.encoded).to match("Summary for #{volunteer.display_name}")
      end

      it "does not show a case contact that did not occurr in the week" do
        create(:case_contact, casa_case: casa_case, occurred_at: Date.today - 8.days)
        expect(mail.body.encoded).to_not match("Most recent contact attempted:")
      end

      it "shows the latest case contact that occurred in the week" do
        most_recent_contact = create(:case_contact, casa_case: casa_case, occurred_at: Date.today - 1.days, notes: "AAAAAAAAAAAAAAAAAAAAAAAA")
        other_contact = create(:case_contact, casa_case: casa_case, occurred_at: Date.today - 3.days, notes: "BBBBBBBBBBBBBBBBBBBB")

        expect(mail.body.encoded).to match("Notes: #{most_recent_contact.notes}")
        expect(mail.body.encoded).to_not match("Notes: #{other_contact.notes}")
      end
    end

    context "when a supervisor has a volunteer who is unassigned from a casa case during the week" do
      let!(:case_assignment) { create(:case_assignment, casa_case: casa_case, volunteer: volunteer, is_active: false, updated_at: Date.today - 2.days) }

      it "shows a summary for a volunteer recently unassigned from the supervisor" do
        expect(mail.body.encoded).to match("Summary for #{volunteer.display_name}")
      end

      it "shows a disclaimer for a volunteer recently unassigned from the supervisor" do
        expect(mail.body.encoded).to match("This case was unassigned from #{volunteer.display_name}")
      end

      it "does not show a case contact that occurred past the unassignment date in the week" do
        contact_past_unassignment = create(:case_contact, casa_case: casa_case, occurred_at: Date.today - 1.days, notes: "AAAAAAAAAAAAAAAAAAAAAAAA")

        expect(mail.body.encoded).to_not match("Notes: #{contact_past_unassignment.notes}")
      end

      it "shows the latest case contact that occurred in the week before the unassignment date" do
        contact_past_unassignment = create(:case_contact, casa_case: casa_case, occurred_at: Date.today - 1.days, notes: "AAAAAAAAAAAAAAAAAAAAAAAA")
        most_recent_contact_before_unassignment = create(:case_contact, casa_case: casa_case, occurred_at: Date.today - 3.days, notes: "BBBBBBBBBBBBBBBBBB")
        older_contact = create(:case_contact, casa_case: casa_case, occurred_at: Date.today - 4.days, notes: "CCCCCCCCCCCCCCCCCCCC")

        expect(mail.body.encoded).to match("Notes: #{most_recent_contact_before_unassignment.notes}")
        expect(mail.body.encoded).to_not match("Notes: #{contact_past_unassignment.notes}")
        expect(mail.body.encoded).to_not match("Notes: #{older_contact.notes}")
      end
    end

    it "does not show a summary for a volunteer unassigned from the supervisor before the week" do
      create(:case_assignment, casa_case: casa_case, volunteer: volunteer, is_active: false, updated_at: Date.today - 8.days)
      expect(mail.body.encoded).to_not match("Summary for #{volunteer.display_name}")
    end

    it "does not show a summary for a case deactivated prior to this week" do
      create(:case_assignment, casa_case: casa_case, is_active: false, updated_at: Date.today - 8.days)
      expect(mail.body.encoded).to_not match("Summary for #{casa_case}")
  end
end
