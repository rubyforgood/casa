require "rails_helper"

RSpec.describe "followups/resolve", :disable_bullet, type: :system do
  let(:admin) { create(:casa_admin) }
  let(:case_contact) { create(:case_contact) }
  let(:volunteer) { create(:volunteer) }
  let(:supervisor) { create(:supervisor) }
  let!(:followup) { create(:followup, case_contact: case_contact) }

  it "changes status of followup to resolved" do
    sign_in admin
    visit casa_case_path(case_contact.casa_case)

    click_button "Resolve"

    expect(case_contact.followups.count).to eq(1)
    expect(case_contact.followups.first.resolved?).to be_truthy
  end

  context "logged in as admin, followup created by volunteer" do
    let(:case_contact) { create(:case_contact, creator: volunteer) }
    let!(:followup) { create(:followup, creator: volunteer, case_contact: case_contact) }

    it "changes status of followup to resolved" do
      sign_in admin
      visit casa_case_path(case_contact.casa_case)

      click_button "Resolve"

      expect(case_contact.followups.count).to eq(1)
      expect(case_contact.followups.first.resolved?).to be_truthy
    end

    it "removes followup icon and button changes back to 'Follow up'" do
      sign_in admin
      visit casa_case_path(case_contact.casa_case)
      expect(page).to have_css("i.fa-exclamation-circle")

      click_button "Resolve"

      expect(page).not_to have_css("i.fa-exclamation-circle")
      expect(page).to have_button("Follow up")
    end
  end

  context "logged in as supervisor, followup created by volunteer" do
    let(:case_contact) { create(:case_contact, creator: supervisor) }
    let!(:followup) { create(:followup, creator: volunteer, case_contact: case_contact) }

    it "changes status of followup to resolved" do
      sign_in supervisor
      visit casa_case_path(case_contact.casa_case)

      click_button "Resolve"

      expect(case_contact.followups.count).to eq(1)
      expect(case_contact.followups.first.resolved?).to be_truthy
    end
  end

  context "logged in as volunteer, followup created by admin" do
    let(:case_contact) { create(:case_contact, creator: volunteer) }
    let(:volunteer) { create(:volunteer) }
    let!(:followup) { create(:followup, creator: admin, case_contact: case_contact) }

    before do
      case_contact.casa_case.assigned_volunteers << volunteer
    end

    it "changes status of followup to resolved" do
      sign_in volunteer
      visit case_contacts_path

      click_button "Resolve"

      expect(case_contact.followups.count).to eq(1)
      expect(case_contact.followups.first.resolved?).to be_truthy
    end
  end
end
