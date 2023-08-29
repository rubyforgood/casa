require "rails_helper"
require "action_view"

RSpec.describe "case_contacts/new", type: :system do
  include ActionView::Helpers::SanitizeHelper

  context "when admin" do
    it "does not display empty or hidden contact type groups; can create CaseContact", js: true do
      organization = build(:casa_org)
      admin = create(:casa_admin, casa_org: organization)
      casa_case = create(:casa_case, :with_case_assignments, casa_org: organization)
      contact_type_group = build(:contact_type_group, casa_org: organization)
      build(:contact_type_group, name: "Empty", casa_org: organization)
      grp_with_hidden = build(:contact_type_group, name: "OnlyHiddenTypes", casa_org: organization)
      create(:contact_type, name: "Hidden", active: false, contact_type_group: grp_with_hidden)
      school = create(:contact_type, name: "School", contact_type_group: contact_type_group)
      therapist = create(:contact_type, name: "Therapist", contact_type_group: contact_type_group)

      sign_in admin

      visit casa_case_path(casa_case.id)

      # assert to wait for page loading, to reduce flakiness
      expect(page).to have_text("CASA Case Details")

      # does not show empty contact type groups
      expect(page).to_not have_text("Empty")

      # does not show contact type groups with only hidden contact types
      expect(page).to_not have_text("Hidden")

      click_on "New Case Contact"

      check "School"
      check "Therapist"
      within "#enter-contact-details" do
        choose "Yes"
      end
      choose "Video"
      fill_in "case_contact_occurred_at", with: "04/04/2020"

      fill_in "case-contact-duration-hours-display", with: "1"
      fill_in "case-contact-duration-minutes-display", with: "45"
      fill_in "case_contact_miles_driven", with: "0"

      expect {
        click_on "Submit"
      }.to change(CaseContact, :count).by(1)

      expect(CaseContact.first.casa_case_id).to eq casa_case.id
      expect(CaseContact.first.contact_types).to match_array([school, therapist])
      expect(CaseContact.first.duration_minutes).to eq 105
    end

    it "should display full text in table if notes are less than 100 characters", js: true do
      organization = build(:casa_org)
      admin = create(:casa_admin, casa_org: organization)
      casa_case = create(:casa_case, :with_case_assignments, casa_org: organization)
      contact_type_group = build(:contact_type_group, casa_org: organization)
      create(:contact_type, name: "School", contact_type_group: contact_type_group)
      create(:contact_type, name: "Therapist", contact_type_group: contact_type_group)
      sign_in admin

      visit casa_case_path(casa_case.id)
      click_on "New Case Contact"
      
      check "School"
      check "Therapist"
      within "#enter-contact-details" do
        choose "Yes"
      end
      choose "Video"
      fill_in "case_contact_occurred_at", with: "04/04/2020"
      fill_in "case-contact-duration-hours-display", with: "1"
      fill_in "case-contact-duration-minutes-display", with: "45"
      fill_in "case_contact_miles_driven", with: "0"

      short_notes = "Hello world!"
      fill_in "Notes", with: short_notes
      click_on "Submit"

      expect(page).to have_text("Confirm Note Content")

      expect {
        click_on "Continue Submitting"
      }.to change(CaseContact, :count).by(1)

      expect(page).to have_text(short_notes)
      expect(page).not_to have_text("Read more")
    end

    it "should allow expanding or hiding if notes are more than 100 characters", js: true do
      organization = build(:casa_org)
      admin = create(:casa_admin, casa_org: organization)
      casa_case = create(:casa_case, :with_case_assignments, casa_org: organization)
      contact_type_group = build(:contact_type_group, casa_org: organization)
      create(:contact_type, name: "School", contact_type_group: contact_type_group)
      create(:contact_type, name: "Therapist", contact_type_group: contact_type_group)

      sign_in admin

      visit casa_case_path(casa_case.id)
      click_on "New Case Contact"

      check "School"
      check "Therapist"
      within "#enter-contact-details" do
        choose "Yes"
      end
      choose "Video"
      fill_in "case_contact_occurred_at", with: "04/04/2020"
      fill_in "case-contact-duration-hours-display", with: "1"
      fill_in "case-contact-duration-minutes-display", with: "45"
      fill_in "case_contact_miles_driven", with: "0"

      long_notes = "Lorem ipsum dolor sit amet, consectetur adipiscing elit." \
        "Nullam id placerat eros. Fusce egestas sem facilisis interdum maximus." \
        "Donec ullamcorper ligula et consectetur placerat. Duis vel purus molestie," \
        "euismod diam pretium, mattis nibh. Fusce eget leo ex. Donec vitae lacus eu" \
        "magna tincidunt placerat. Mauris nibh nibh, venenatis sit amet libero in," \

      fill_in "Notes", with: long_notes
      click_on "Submit"

      expect(page).to have_text("Confirm Note Content")
      expect {
        click_on "Continue Submitting"
      }.to change(CaseContact, :count).by(1)

      expected_text = long_notes.truncate(100)
      expect(page).to have_text("Read more")
      expect(page).to have_text(expected_text)

      click_link "Read more"

      expect(page).to have_text(long_notes)
    end

    context "with invalid inputs" do
      it "does not submit the form" do
        organization = build(:casa_org)
        admin = create(:casa_admin, casa_org: organization)
        casa_case = create(:casa_case, :with_case_assignments, casa_org: organization)
        contact_type_group = build(:contact_type_group, casa_org: organization)
        create(:contact_type, name: "School", contact_type_group: contact_type_group)
        create(:contact_type, name: "Therapist", contact_type_group: contact_type_group)

        sign_in admin

        visit casa_case_path(casa_case.id)
        click_on "New Case Contact"

        check "School"
        check "Therapist"
        within "#enter-contact-details" do
          choose "Yes"
        end
        choose "Video"
        fill_in "case_contact_occurred_at", with: "04/04/2020"
        fill_in "case-contact-duration-hours-display", with: "0"
        fill_in "case-contact-duration-minutes-display", with: "5"

        expect {
          click_on "Submit"
        }.not_to change(CaseContact, :count)
      end
    end

    context "with HTML in notes" do
      it "renders HTML correctly on the index page", js: true do
        organization = build(:casa_org)
        admin = create(:casa_admin, casa_org: organization)
        casa_case = create(:casa_case, :with_case_assignments, casa_org: organization)
        contact_type_group = build(:contact_type_group, casa_org: organization)
        create(:contact_type, name: "School", contact_type_group: contact_type_group)
        create(:contact_type, name: "Therapist", contact_type_group: contact_type_group)

        sign_in admin

        visit casa_case_path(casa_case.id)
        click_on "New Case Contact"

        fill_out_minimum_required_fields_for_case_contact_form

        note_content = "<h1>Hello world</h1>"

        fill_in "Notes", with: note_content
        click_on "Submit"

        expect(page).to have_text("Confirm Note Content")

        expect {
          click_on "Continue Submitting"
        }.to change(CaseContact, :count).by(1)

        expect(page).to have_css("#case_contacts_list h1", text: "Hello world")
      end
    end
  end

  context "mutliple contact type groups" do
    it "should check the correct box when clicking the label" do
      organization = build(:casa_org)
      admin = build(:casa_admin, casa_org: organization)
      casa_case = create(:casa_case, :with_case_assignments, casa_org: organization)
      group_1 = build_stubbed(:contact_type_group, casa_org: organization)
      create(:contact_type, name: "School", contact_type_group: group_1)
      group_2 = build(:contact_type_group, casa_org: organization)
      create(:contact_type, name: "Parent", contact_type_group: group_2)

      sign_in admin
      visit new_case_contact_path(casa_case.id)

      expect { check "Parent" }.not_to raise_error
    end

    it "shows the contact type groups, and their contact type alphabetically", :aggregate_failures do
      organization = build(:casa_org)
      admin = build(:casa_admin, casa_org: organization)
      casa_case = create(:casa_case, :with_case_assignments, casa_org: organization)
      group_1 = create(:contact_type_group, name: "Placement", casa_org: organization)
      group_2 = create(:contact_type_group, name: "Education", casa_org: organization)
      create(:contact_type, name: "School", contact_type_group: group_1)
      create(:contact_type, name: "Sports", contact_type_group: group_1)
      create(:contact_type, name: "Caregiver Family", contact_type_group: group_2)
      create(:contact_type, name: "Foster Parent", contact_type_group: group_2)

      sign_in admin
      visit(new_case_contact_path(casa_case.id))

      expect(index_of("Education")).to be < index_of("Placement")
      expect(index_of("School")).to be < index_of("Sports")
      expect(index_of("Caregiver Family")).to be < index_of("Foster Parent")
      expect(index_of("School")).to be > index_of("Caregiver Family")
    end

    def index_of(text)
      page.text.index(text)
    end
  end

  context "volunteer user" do
    it "is successful without a. Miles Driven or driving reimbursement", js: true do
      FeatureFlagService.enable!(FeatureFlagService::SHOW_ADDITIONAL_EXPENSES_FLAG)
      organization = build(:casa_org)
      build(:contact_type_group, name: "Empty", casa_org: organization)
      grp_with_hidden = build(:contact_type_group, name: "OnlyHiddenTypes", casa_org: organization)
      build(:contact_type, name: "Hidden", active: false, contact_type_group: grp_with_hidden)
      volunteer = create(:volunteer, :with_casa_cases)
      volunteer_casa_case_one = volunteer.casa_cases.first
      create_contact_types(volunteer_casa_case_one.casa_org)

      sign_in volunteer

      visit new_case_contact_path(volunteer_casa_case_one.id)
      check volunteer_casa_case_one.case_number
      check "School"
      check "Therapist"
      within "#enter-contact-details" do
        choose "Yes"
      end
      choose "In Person"
      fill_in "case-contact-duration-hours-display", with: "1"
      fill_in "case-contact-duration-minutes-display", with: "45"
      fill_in "c. Occurred On", with: "04/04/2020"
      choose "case_contact_want_driving_reimbursement_false"

      fill_in "Notes", with: "Hello world"

      expect(page).not_to have_text("error")
      expect(page).to_not have_text("Empty")
      expect(page).to_not have_text("Hidden")

      click_on "Submit"
      expect(page).to have_text("Confirm Note Content")
      click_on "Continue Submitting"

      expect(volunteer_casa_case_one.case_contacts.length).to eq(1)
      case_contact = volunteer_casa_case_one.case_contacts.first
      expect(case_contact.casa_case_id).to eq volunteer_casa_case_one.id
      expect(case_contact.contact_types.map(&:name)).to include "School"
      expect(case_contact.contact_types.map(&:name)).to include "Therapist"
      expect(case_contact.duration_minutes).to eq 105
    end

    it "autosaves notes", js: true do
      volunteer = create(:volunteer, :with_casa_cases)
      volunteer_casa_case_one = volunteer.casa_cases.first
      create_contact_types(volunteer_casa_case_one.casa_org)

      sign_in volunteer

      visit new_case_contact_path(volunteer_casa_case_one.id)

      check volunteer_casa_case_one.case_number
      check "School"
      check "Therapist"
      within "#enter-contact-details" do
        choose "Yes"
      end
      choose "In Person"
      fill_in "case-contact-duration-hours-display", with: "1"
      fill_in "case-contact-duration-minutes-display", with: "45"
      fill_in "c. Occurred On", with: "2020/4/4"
      fill_in "a. Miles Driven", with: "30"
      choose "case_contact_want_driving_reimbursement_false"
      fill_in "Notes", with: "Hello world"

      click_on "Submit"
      expect(page).to have_text("Confirm Note Content")
      click_on "Continue Submitting"

      find("button#profile").click
      click_on "Sign Out"

      sign_in volunteer

      case_contact_id = volunteer_casa_case_one.case_contacts.first.id
      visit edit_case_contact_path(case_contact_id)

      expect(page).to have_checked_field(volunteer_casa_case_one.case_number, disabled: true)
      expect(page).to have_checked_field("School")
      expect(page).to have_checked_field("Therapist")
      expect(page).to have_checked_field("Yes")
      expect(page).to have_checked_field("In Person")
      expect(page).to have_field("case-contact-duration-hours-display", with: "1")
      expect(page).to have_field("case-contact-duration-minutes-display", with: "45")
      expect(page).to have_field("c. Occurred On", with: "2020-04-04")
      expect(page).to have_field("a. Miles Driven", with: "30")
      expect(page).to have_checked_field("case_contact_want_driving_reimbursement_false")
      expect(page).not_to have_checked_field("case_contact_want_driving_reimbursement_true")
      expect(page).to have_field("Notes", with: "Hello world")
    end

    it "delete local storage notes after successfuly submited", js: true do
      volunteer = create(:volunteer, :with_casa_cases)
      volunteer_casa_case_one = volunteer.casa_cases.first
      create_contact_types(volunteer_casa_case_one.casa_org)

      sign_in volunteer
      visit new_case_contact_path

      check volunteer_casa_case_one.case_number
      check "School"
      check "Therapist"
      within "#enter-contact-details" do
        choose "Yes"
      end
      choose "In Person"
      fill_in "case-contact-duration-hours-display", with: "1"
      fill_in "case-contact-duration-minutes-display", with: "45"
      fill_in "a. Miles Driven", with: "30"
      choose "case_contact_want_driving_reimbursement_false"
      fill_in "Notes", with: "Hello world"

      # Allow 5 seconds for the Notes to be saved in localstorage
      sleep 5
      click_on "Submit"
      click_on "Continue Submitting"

      expect(page).to have_text "successfully created"

      visit new_case_contact_path

      expect(page).to_not have_field("Notes", with: "Hello world")
    end

    it "submits the form when no note was added", js: true do
      volunteer = create(:volunteer, :with_casa_cases)
      volunteer_casa_case_one = volunteer.casa_cases.first
      create_contact_types(volunteer_casa_case_one.casa_org)

      sign_in volunteer

      visit new_case_contact_path

      check volunteer_casa_case_one.case_number
      check "School"
      check "Therapist"
      within "#enter-contact-details" do
        choose "Yes"
      end
      choose "In Person"
      fill_in "case-contact-duration-hours-display", with: "1"
      fill_in "case-contact-duration-minutes-display", with: "45"
      fill_in "c. Occurred On", with: "04/04/2020"
      fill_in "a. Miles Driven", with: "30"
      choose "case_contact_want_driving_reimbursement_false"
      fill_in "Notes", with: ""

      expect(page).not_to have_text("error")
      expect {
        click_on "Submit"
      }.to change(CaseContact, :count).by(1)

      expect(CaseContact.first.notes).to eq ""
    end

    it "submits the form when note is added and confirmed", js: true do
      volunteer = create(:volunteer, :with_casa_cases)
      volunteer_casa_case_one = volunteer.casa_cases.first
      create_contact_types(volunteer_casa_case_one.casa_org)

      sign_in volunteer

      visit new_case_contact_path

      check volunteer_casa_case_one.case_number
      check "School"
      check "Therapist"
      within "#enter-contact-details" do
        choose "Yes"
      end
      choose "In Person"
      fill_in "case-contact-duration-hours-display", with: "1"
      fill_in "case-contact-duration-minutes-display", with: "45"
      fill_in "c. Occurred On", with: "04/04/2020"
      fill_in "a. Miles Driven", with: "30"
      choose "case_contact_want_driving_reimbursement_false"
      fill_in "Notes", with: "This is the note"

      expect(page).not_to have_text("error")
      click_on "Submit"
      expect(page).to have_text("Confirm Note Content")
      expect {
        click_on "Continue Submitting"
      }.to change(CaseContact, :count).by(1)

      expect(CaseContact.first.notes).to eq "This is the note"
    end

    it "does not submit the form when note is added but not confirmed", js: true do
      volunteer = create(:volunteer, :with_casa_cases)
      volunteer_casa_case_one = volunteer.casa_cases.first
      create_contact_types(volunteer_casa_case_one.casa_org)

      sign_in volunteer

      visit new_case_contact_path

      check volunteer_casa_case_one.case_number
      check "School"
      check "Therapist"
      within "#enter-contact-details" do
        choose "Yes"
      end
      choose "In Person"
      fill_in "case-contact-duration-hours-display", with: "1"
      fill_in "case-contact-duration-minutes-display", with: "45"
      fill_in "c. Occurred On", with: "04/04/2020"
      fill_in "a. Miles Driven", with: "30"
      choose "case_contact_want_driving_reimbursement_false"
      fill_in "Notes", with: "This is the note"

      expect(page).not_to have_text("error")
      click_on "Submit"
      expect(page).to have_text("Confirm Note Content")
      expect {
        click_on "Go Back to Form"
      }.not_to change(CaseContact, :count)
    end

    context "with invalid inputs" do
      let(:name) do
        fill_in "c. Occurred On", with: 2.days.ago.strftime("%Y/%m/%d\n")
      end

      it "re-renders the form with errors, but preserving all previously entered selections", js: true do
        volunteer = create(:volunteer, :with_casa_cases)
        volunteer_casa_case_one = volunteer.casa_cases.first
        future_date = 2.days.from_now
        create_contact_types(volunteer_casa_case_one.casa_org)

        sign_in volunteer

        visit new_case_contact_path

        check volunteer_casa_case_one.case_number
        check "School"
        check "Therapist"
        within "#enter-contact-details" do
          choose "Yes"
        end
        choose "In Person"
        fill_in "case-contact-duration-hours-display", with: "1"
        fill_in "case-contact-duration-minutes-display", with: "45"
        # Future date: invalid

        alert_msg = page.accept_alert do
          fill_in "c. Occurred On", with: future_date.strftime("%Y/%m/%d\n")
        end
        expect(alert_msg).to eq("Case Contact Occurrences cannot be in the future.")
        expect(page.find("#case_contact_occurred_at").value).to eq(Date.current.strftime("%Y-%m-%d"))
        # js validation

        name

        fill_in "a. Miles Driven", with: "0"
        choose "case_contact_want_driving_reimbursement_true"
        fill_in "case_contact_casa_case_attributes_volunteers_attributes_0_address_attributes_content",	with: "123 str"
        fill_in "Notes", with: "Hello world"

        click_on "Submit"
        expect(page).to have_text("Confirm Note Content")
        expect {
          click_on "Continue Submitting"
        }.not_to change(CaseContact, :count)

        expect(page).to have_text("Must enter miles driven to receive driving reimbursement.") # rails validation
        expect(page).to have_checked_field(volunteer_casa_case_one.case_number)
        expect(page).to have_unchecked_field("Attorney")
        expect(page).to have_checked_field("School")
        expect(page).to have_checked_field("Therapist")
        expect(page).to have_checked_field("Yes")
        expect(page).to have_checked_field("In Person")
        expect(page).to have_field("case-contact-duration-hours-display", with: "1")
        expect(page).to have_field("case-contact-duration-minutes-display", with: "45")
        expect(page).to have_field("c. Occurred On", with: 2.days.ago.strftime("%Y-%m-%d"))
        expect(page).to have_field("a. Miles Driven", with: "0")
        expect(page).to have_checked_field("case_contact_want_driving_reimbursement_true")
        expect(page).not_to have_checked_field("case_contact_want_driving_reimbursement_false")
        expect(page).to have_field("Notes", with: "Hello world")
      end

      it "sets occured date field to current date when a future date is selected", js: true do
        volunteer = create(:volunteer, :with_casa_cases)
        volunteer_casa_case_one = volunteer.casa_cases.first
        create_contact_types(volunteer_casa_case_one.casa_org)

        current_date_string = DateTime.now.strftime("%Y-%m-%d")
        tomorrow_date_string = (DateTime.now + 1).strftime("%Y-%m-%d")

        sign_in volunteer

        visit new_case_contact_path

        fill_in "case_contact_occurred_at", with: tomorrow_date_string

        find("body").click

        page.accept_alert

        field_value = page.find_field("case_contact_occurred_at").value

        expect(field_value).to eq(current_date_string)
      end
    end

    context "with no contact types set for the volunteer's cases" do
      it "renders all of the org's contact types", js: true do
        org = build(:casa_org)
        create_contact_types(org)
        volunteer = build(:volunteer, :with_casa_cases, casa_org: org)

        sign_in volunteer

        visit new_case_contact_path

        expect(page).to have_field("Attorney")
        expect(page).to have_field("School")
        expect(page).to have_field("Therapist")
      end
    end

    context "with specific contact types allowed for the volunteer's cases" do
      it "only renders contact types that are allowed for the volunteer's cases", js: true do
        org = build(:casa_org)
        contact_type_group = create_contact_types(org)
        volunteer = create(:volunteer, :with_casa_cases, casa_org: org)
        contact_types_for_cases = contact_type_group.contact_types.reject { |ct| ct.name == "Attorney" }
        assign_contact_types_to_cases(volunteer.casa_cases, contact_types_for_cases)

        sign_in volunteer

        visit new_case_contact_path

        expect(page).not_to have_field("Attorney")
        expect(page).to have_field("School")
        expect(page).to have_field("Therapist")
      end
    end

    context "when driving reimbursement is hidden by the CASA org" do
      it "does not show for case_contacts" do
        org = build(:casa_org, show_driving_reimbursement: false)
        contact_type_group = create_contact_types(org)
        volunteer = create(:volunteer, :with_casa_cases, casa_org: org)
        contact_types_for_cases = contact_type_group.contact_types.reject { |ct| ct.name == "Attorney" }
        assign_contact_types_to_cases(volunteer.casa_cases, contact_types_for_cases)

        sign_in volunteer

        visit new_case_contact_path

        expect(page).not_to have_field("b. Want Driving Reimbursement")
      end
    end

    context "when driving reimbursement is hidden when volunteer not allowed to request" do
      it "does not show for case_contacts" do
        org = build(:casa_org, show_driving_reimbursement: true)
        contact_type_group = create_contact_types(org)
        volunteer = create(:volunteer, :with_disasllow_reimbursement, casa_org: org)
        contact_types_for_cases = contact_type_group.contact_types.reject { |ct| ct.name == "Attorney" }
        assign_contact_types_to_cases(volunteer.casa_cases, contact_types_for_cases)

        sign_in volunteer

        visit new_case_contact_path

        expect(page).not_to have_field("b. Want Driving Reimbursement")
      end
    end

    describe "case default selection" do
      let(:volunteer) { create(:volunteer, :with_casa_cases) }
      let(:first_case) { volunteer.casa_cases.first }
      let(:second_case) { volunteer.casa_cases.second }

      before(:each) do
        sign_in volunteer
      end

      it "selects no cases" do
        visit new_case_contact_path

        expect(page).not_to have_checked_field(first_case.case_number)
        expect(page).not_to have_checked_field(second_case.case_number)
      end

      context "when there are params defined" do
        it "select the cases defined in the params" do
          visit new_case_contact_path(case_contact: {casa_case_id: first_case.id})

          expect(page).to have_checked_field(first_case.case_number)
          expect(page).not_to have_checked_field(second_case.case_number)
        end
      end

      context "when there's only one case" do
        it "selects the only case" do
          second_case.destroy!
          visit new_case_contact_path

          expect(page).to have_checked_field(first_case.case_number)
        end
      end
    end

    private

    def create_contact_types(org)
      create(:contact_type_group, casa_org: org).tap do |group|
        create(:contact_type, contact_type_group: group, name: "Attorney")
        create(:contact_type, contact_type_group: group, name: "School")
        create(:contact_type, contact_type_group: group, name: "Therapist")
      end
    end

    def assign_contact_types_to_cases(cases, contact_types)
      cases.each do |c|
        c.contact_types = contact_types
        c.save
      end
    end
  end
end
