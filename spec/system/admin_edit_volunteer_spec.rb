require "rails_helper"

RSpec.describe "Admin: Editing Volunteers", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org_id: organization.id) }
  let(:volunteer) { create(:volunteer, casa_org_id: organization.id) }

  describe "updating volunteer personal data" do
    before do
      sign_in admin
      visit edit_volunteer_path(volunteer)
    end

    context "with valid data" do
      it "updates successfully" do
        fill_in "volunteer_email", with: "newemail@example.com"
        fill_in "volunteer_display_name", with: "Mickey Mouse"
        click_on "Submit"
        expect(page).to have_text "Volunteer was successfully updated."
      end
    end

    context "with invalid data" do
      it "shows error message for duplicate email" do
        fill_in "volunteer_email", with: admin.email
        fill_in "volunteer_display_name", with: "Mickey Mouse"
        click_on "Submit"
        expect(page).to have_text "already been taken"
      end

      it "shows error message for empty fields" do
        fill_in "volunteer_email", with: ""
        fill_in "volunteer_display_name", with: ""
        click_on "Submit"
        expect(page).to have_text "can't be blank"
      end
    end
  end

  it "saves the user as inactive, but only if the admin confirms" do
    sign_in admin
    visit edit_volunteer_path(volunteer)

    dismiss_confirm do
      click_on "Deactivate volunteer"
    end
    expect(page).not_to have_text("Volunteer was deactivated on")

    accept_confirm do
      click_on "Deactivate volunteer"
    end
    expect(page).to have_text("Volunteer was deactivated on")

    expect(volunteer.reload).not_to be_active
  end

  it "allows an admin to reactivate a volunteer" do
    inactive_volunteer = create(:volunteer, casa_org_id: organization.id)
    inactive_volunteer.deactivate

    sign_in admin

    visit edit_volunteer_path(inactive_volunteer)

    click_on "Activate volunteer"

    expect(page).not_to have_text("Volunteer was deactivated on")

    expect(inactive_volunteer.reload).to be_active
  end

  context "with a deactivated case" do
    it "displays inactive message" do
      deactivated_casa_case = create(:casa_case, active: false, casa_org: volunteer.casa_org, volunteers: [volunteer])
      sign_in admin

      visit edit_volunteer_path(volunteer)
      expect(page).to have_text "Case was deactivated on: #{deactivated_casa_case.updated_at.strftime("%m-%d-%Y")}"
    end
  end
end
