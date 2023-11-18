require "rails_helper"

RSpec.describe "case_contacts/edit", type: :system do
  let(:organization) { build(:casa_org) }
  let(:casa_case) { create(:casa_case, :with_case_assignments, casa_org: organization) }
  let!(:case_contact) { create(:case_contact, duration_minutes: 105, casa_case: casa_case) }

  context "when admin" do
    let(:admin) { create(:casa_admin, casa_org: organization) }

    it "admin successfully edits case contact", js: true do
      sign_in admin

      visit edit_case_contact_path(case_contact)

      within "#enter-contact-details" do
        choose "Yes"
      end
      choose "Letter"

      click_on "Submit"

      case_contact.reload
      expect(page).to have_text "Case contact created at #{case_contact.created_at.strftime("%-I:%-M %p on %m-%e-%Y")}, was successfully updated."
      expect(case_contact.casa_case_id).to eq casa_case.id
      expect(case_contact.duration_minutes).to eq 105
      expect(case_contact.medium_type).to eq "letter"
      expect(case_contact.contact_made).to eq true
    end

    it "admin successfully edits case contact with mileage reimbursement", js: true do
      casa_case = create(:casa_case, :with_one_case_assignment, casa_org: organization)
      case_contact = create(:case_contact, duration_minutes: 105, casa_case: casa_case)
      sign_in admin

      visit edit_case_contact_path(case_contact)

      within "#enter-contact-details" do
        choose "Yes"
      end
      choose "In Person"
      fill_in "case_contact_duration_hours", with: "1"
      fill_in "case_contact_duration_minutes", with: "45"
      fill_in "c. Occurred On", with: "04/04/2020"
      fill_in "a. Miles Driven", with: "10"
      choose "case_contact_want_driving_reimbursement_true"
      expect(page).to have_selector("#case_contact_casa_case_attributes_volunteers_attributes_0_address_attributes_content")
      fill_in "case_contact_casa_case_attributes_volunteers_attributes_0_address_attributes_content",	with: "123 str"
      click_on "Submit"
      case_contact.reload
      expect(page).to have_text "Case contact created at #{case_contact.created_at.strftime("%-I:%-M %p on %m-%e-%Y")}, was successfully updated."
      expect(case_contact.casa_case.volunteers[0].address.content).to eq "123 str"
      expect(case_contact.casa_case_id).to eq casa_case.id
      expect(case_contact.duration_minutes).to eq 105
      expect(case_contact.medium_type).to eq "in-person"
      expect(case_contact.contact_made).to eq true
    end

    it "admin fails to edit volunteer address for case contact  with mileage reimbursement", js: true do
      sign_in admin

      visit edit_case_contact_path(case_contact)

      within "#enter-contact-details" do
        choose "Yes"
      end
      choose "In Person"
      fill_in "case_contact_duration_hours", with: "1"
      fill_in "case_contact_duration_minutes", with: "45"
      fill_in "c. Occurred On", with: "04/04/2020"
      fill_in "a. Miles Driven", with: "10"
      choose "case_contact_want_driving_reimbursement_true"
      expect(page).not_to have_selector("#case_contact_casa_case_attributes_volunteers_attributes_0_address_attributes_content")
      expect(find("#case_contact_no_address_content").value)
        .to eq("There are two volunteers assigned to this case and \
you are trying to set the address for both of them. This is not currently possible.")
    end

    context "is part of a different organization" do
      let(:other_organization) { build(:casa_org) }
      let(:admin) { create(:casa_admin, casa_org: other_organization) }

      it "fails across organizations" do
        sign_in admin

        visit edit_case_contact_path(case_contact)
        expect(current_path).to eq supervisors_path
      end
    end
  end

  context "volunteer user" do
    let(:volunteer) { create(:volunteer, casa_org: organization) }
    let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }

    it "is successful", js: true do
      case_contact = create(:case_contact, duration_minutes: 105, casa_case: casa_case, creator: volunteer)
      sign_in volunteer
      visit edit_case_contact_path(case_contact)

      within "#enter-contact-details" do
        choose "Yes"
      end
      choose "Letter"

      click_on "Submit"

      case_contact.reload
      expect(page).to have_text "Case contact created at #{case_contact.created_at.strftime("%-I:%-M %p on %m-%e-%Y")}, was successfully updated."
      expect(case_contact.casa_case_id).to eq casa_case.id
      expect(case_contact.duration_minutes).to eq 105
      expect(case_contact.medium_type).to eq "letter"
      expect(case_contact.contact_made).to eq true
    end

    it "is successful with mileage reimbursement on", js: true do
      case_contact = create(:case_contact, duration_minutes: 105, casa_case: casa_case, creator: volunteer)
      sign_in volunteer
      visit edit_case_contact_path(case_contact)

      within "#enter-contact-details" do
        choose "Yes"
      end

      choose "In Person"
      fill_in "case_contact_duration_hours", with: "1"
      fill_in "case_contact_duration_minutes", with: "45"
      fill_in "c. Occurred On", with: "04/04/2020"
      fill_in "a. Miles Driven", with: "10"
      choose "case_contact_want_driving_reimbursement_true"
      expect(page).to have_selector("#case_contact_casa_case_attributes_volunteers_attributes_0_address_attributes_content")
      fill_in "case_contact_casa_case_attributes_volunteers_attributes_0_address_attributes_content",	with: "123 str"

      click_on "Submit"

      case_contact.reload
      volunteer.reload
      expect(page).to have_text "Case contact created at #{case_contact.created_at.strftime("%-I:%-M %p on %m-%e-%Y")}, was successfully updated."
      expect(volunteer.address.content).to eq "123 str"
      expect(case_contact.casa_case_id).to eq casa_case.id
      expect(case_contact.duration_minutes).to eq 105
      expect(case_contact.medium_type).to eq "in-person"
      expect(case_contact.contact_made).to eq true
    end

    it "autosaves notes", js: true do
      case_contact = create(:case_contact, duration_minutes: 105, casa_case: casa_case, creator: volunteer, notes: "Hello from the other side")
      sign_in volunteer
      visit edit_case_contact_path(case_contact)

      within "#enter-contact-details" do
        choose "Yes"
      end

      fill_in "Notes", with: "Hello world"

      find("button#profile").click
      click_on "Sign Out"

      sign_in volunteer

      visit edit_case_contact_path(case_contact)

      expect(page).to have_field("Notes", with: "Hello world")
    end
  end
end
