require "rails_helper"

RSpec.describe "followups/resolve", type: :system do
  let(:admin) { create(:casa_admin) }
  let(:supervisor) { create(:supervisor) }
  let(:volunteer) { create(:volunteer) }
  let(:case_contact) { create(:case_contact, creator: volunteer) }

  context 'logged in as admin, followup created by volunteer' do
    let!(:followup) { create(:followup, creator: volunteer, case_contact: case_contact) }

    it "changes status of followup to resolved" do
      sign_in admin
      visit casa_case_path(case_contact.casa_case)

      click_button "Resolve"

      expect(case_contact.followups.count).to eq(1)
      expect(case_contact.followups.first.resolved?).to be_truthy
    end
  end

  context 'logged in as supervisor, followup created by volunteer' do
    let!(:followup) { create(:followup, creator: volunteer, case_contact: case_contact) }

    it "changes status of followup to resolved" do
      sign_in supervisor
      visit casa_case_path(case_contact.casa_case)

      click_button "Resolve"

      expect(case_contact.followups.count).to eq(1)
      expect(case_contact.followups.first.resolved?).to be_truthy
    end
  end

  context 'logged in as volunteer, followup created by admin' do
    let!(:followup) { create(:followup, creator: admin, case_contact: case_contact) }

    it "changes status of followup to resolved" do
      casa_case = case_contact.casa_case
      casa_case.assigned_volunteers << volunteer
      sign_in volunteer
      visit case_contacts_path

      click_button "Resolve"

      expect(case_contact.followups.count).to eq(1)
      expect(case_contact.followups.first.resolved?).to be_truthy
    end
  end
end
