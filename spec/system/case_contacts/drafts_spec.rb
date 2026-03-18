require "rails_helper"

RSpec.describe "case_contacts/drafts", type: :system do
  let(:organization) { build(:casa_org) }
  let(:admin) { build(:casa_admin, casa_org: organization) }

  context "with case contacts" do
    let!(:casa_case) { build(:casa_case, casa_org: organization) }
    let!(:other_org_case) { build(:case_contact, notes: "NOTE_A") }
    let!(:past_contact) { build(:case_contact, casa_case: casa_case, occurred_at: 3.weeks.ago, notes: "NOTE_B") }
    let!(:past_contact_draft) { create(:case_contact, :started_status, casa_case: casa_case, occurred_at: 3.weeks.ago, notes: "NOTE_C") }
    let!(:recent_contact) { build(:case_contact, casa_case: casa_case, occurred_at: 3.days.ago, notes: "NOTE_D") }
    let!(:recent_contact_draft) { create(:case_contact, :started_status, casa_case: casa_case, occurred_at: 3.days.ago, notes: "NOTE_E") }

    it "shows only same orgs drafts" do
      sign_in admin

      visit case_contacts_drafts_path

      expect(page).not_to have_content("NOTE_A")
      expect(page).not_to have_content("NOTE_B")
      expect(page).to have_content("NOTE_C")
      expect(page).not_to have_content("NOTE_D")
      expect(page).to have_content("NOTE_E")
    end
  end
end
