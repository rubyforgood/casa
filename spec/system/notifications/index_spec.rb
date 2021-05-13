require "rails_helper"

RSpec.describe "notifications/index", :disable_bullet, type: :system do
  let(:admin) { create(:casa_admin) }
  let(:volunteer) { create(:volunteer) }
  let(:case_contact) { create(:case_contact, creator: volunteer) }

  context "FollowupResolvedNotification" do
    let!(:followup) { create(:followup, creator: admin, case_contact: case_contact) }
    it "lists my notifcations" do
      casa_case = case_contact.casa_case
      casa_case.assigned_volunteers << volunteer
      sign_in volunteer
      visit case_contacts_path
      click_button "Resolve"

      sign_in admin
      visit notifications_path

      notification_message = "#{volunteer.display_name} resolved a follow up. Click to see more."
      expect(page).to have_text(notification_message)
      expect(page).to have_text("Followup resolved")
    end
  end

  context "FollowupNotification" do
    it "lists my notifcations" do
      casa_case = case_contact.casa_case
      casa_case.assigned_volunteers << volunteer
      sign_in admin
      visit casa_case_path(casa_case)
      click_button "Follow up"

      sign_in volunteer
      visit notifications_path

      notification_message = "#{admin.display_name} has flagged a Case Contact that needs follow up. Click to see more."
      expect(page).to have_text(notification_message)
      expect(page).to have_text("New followup")
    end
  end
end
