require "rails_helper"

RSpec.describe "followups/resolve", type: :system, js: true do
  let(:casa_org) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: casa_org) }
  let(:supervisor) { build(:supervisor, casa_org: casa_org) }
  let(:volunteer) { build(:volunteer, casa_org: casa_org) }
  let(:casa_case) { create(:casa_case, casa_org: casa_org) }
  let(:cc_creator) { admin }
  let(:followup_creator) { volunteer }
  let(:case_contact) { build(:case_contact, casa_case: casa_case, creator: cc_creator) }
  let!(:followup) { create(:followup, case_contact: case_contact, creator: followup_creator) }

  it "changes status of followup to resolved" do
    sign_in admin
    visit casa_case_path(case_contact.casa_case)

    click_button "Resolve Reminder"

    expect(case_contact.followups.count).to eq(1)
    expect(case_contact.followups.first.resolved?).to be_truthy
  end

  context "logged in as admin, followup created by volunteer" do
    let(:cc_creator) { volunteer }
    let(:followup_creator) { volunteer }

    it "changes status of followup to resolved" do
      sign_in admin
      visit casa_case_path(case_contact.casa_case)

      click_button "Resolve Reminder"

      expect(case_contact.followups.count).to eq(1)
      expect(case_contact.followups.first.resolved?).to be_truthy
    end

    it "removes followup icon and button changes back to 'Make Reminder'" do
      sign_in admin
      visit casa_case_path(case_contact.casa_case)

      click_button "Resolve Reminder"

      expect(page).to have_button("Make Reminder")
    end
  end

  context "logged in as supervisor, followup created by volunteer" do
    let(:cc_creator) { supervisor }
    let(:followup_creator) { volunteer }

    it "changes status of followup to resolved" do
      sign_in supervisor
      visit casa_case_path(case_contact.casa_case)

      click_button "Resolve Reminder"

      expect(case_contact.followups.count).to eq(1)
      expect(case_contact.followups.first.resolved?).to be_truthy
    end
  end

  context "logged in as volunteer, followup created by admin" do
    let(:cc_creator) { volunteer }
    let(:followup_creator) { admin }

    before do
      case_contact.casa_case.assigned_volunteers << volunteer
    end

    it "changes status of followup to resolved" do
      sign_in volunteer
      visit case_contacts_path

      click_button "Resolve Reminder"

      expect(case_contact.followups.count).to eq(1)
      expect(case_contact.followups.first.resolved?).to be_truthy
    end
  end
end
