require "rails_helper"

RSpec.describe DraftCaseContactCleanupService do
  describe ".call" do
    let!(:past_expiration) { 8.days.ago }
    let!(:past_exp_without_case) { 2.days.ago }
    let!(:active_case_contact) { create(:case_contact, status: "active") }
    let!(:new_draft_case_contact) { create(:case_contact, status: "started", created_at: Time.now, draft_case_ids: []) }
    let!(:draft_case_contact_without_draft_case_id) { create(:case_contact, status: "started", created_at: past_exp_without_case, draft_case_ids: []) }
    let!(:draft_case_contact_with_draft_case_id) { create(:case_contact, status: "started", created_at: past_exp_without_case, draft_case_ids: [1]) }
    let!(:eight_day_draft_case_contact) { create(:case_contact, status: "details", created_at: past_expiration) }
    let!(:eight_day_active_case_contact) { create(:case_contact, status: "active", created_at: past_expiration) }

    it "returns drafts not attached to cases and drafts older than a week" do
      expect { described_class.call }.to change { CaseContact.count }.by(-2)

      expect(CaseContact.where(id: draft_case_contact_without_draft_case_id.id)).to be_empty
      expect(CaseContact.where(id: eight_day_draft_case_contact.id)).to be_empty
    end
  end
end
