require "rails_helper"

RSpec.describe "case_contacts/new", :disable_bullet, type: :system do
  context "when admin" do
    let(:organization) { create(:casa_org) }
    let(:admin) { create(:casa_admin, casa_org: organization) }
    let(:casa_case) { create(:casa_case, casa_org: organization) }
    let(:contact_type_group) { create(:contact_type_group, casa_org: organization) }
    let!(:empty) { create(:contact_type_group, name: "Empty", casa_org: organization) }
    let!(:grp_with_hidden) { create(:contact_type_group, name: "OnlyHiddenTypes", casa_org: organization) }
    let!(:hidden_type) { create(:contact_type, name: "Hidden", active: false, contact_type_group: grp_with_hidden) }
    let!(:school) { create(:contact_type, name: "School", contact_type_group: contact_type_group) }
    let!(:therapist) { create(:contact_type, name: "Therapist", contact_type_group: contact_type_group) }

    before do
      sign_in admin

      visit casa_case_path(casa_case.id)
      click_on "New Case Contact"

      check "School"
      check "Therapist"
      choose "Yes"
      select "Video", from: "case_contact[medium_type]"
      fill_in "case_contact_occurred_at", with: "04/04/2020"
    end

    it "is successful", js: true do
      fill_in "case-contact-duration-hours", with: "1"
      fill_in "case-contact-duration-minutes", with: "45"

      expect {
        click_on "Submit"
      }.to change(CaseContact, :count).by(1)

      expect(CaseContact.first.casa_case_id).to eq casa_case.id
      expect(CaseContact.first.contact_types).to match_array([school, therapist])
      expect(CaseContact.first.duration_minutes).to eq 105
    end

    it "does not show empty contact type groups" do
      expect(page).to_not have_text("Empty")
    end

    it "does not show contact type groups with only hidden contact types" do
      expect(page).to_not have_text("Hidden")
    end

    it "should display full text in table if notes are less than 100 characters", js: true do
      fill_in "case-contact-duration-hours", with: "1"
      fill_in "case-contact-duration-minutes", with: "45"

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
      fill_in "case-contact-duration-hours", with: "1"
      fill_in "case-contact-duration-minutes", with: "45"

      long_notes = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."\
        "Nullam id placerat eros. Fusce egestas sem facilisis interdum maximus."\
        "Donec ullamcorper ligula et consectetur placerat. Duis vel purus molestie,"\
        "euismod diam pretium, mattis nibh. Fusce eget leo ex. Donec vitae lacus eu"\
        "magna tincidunt placerat. Mauris nibh nibh, venenatis sit amet libero in,"\

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

      expect(page).to have_text("Hide")
      expect(page).to have_text(long_notes)
      expect(page).not_to have_text("Read more")
    end

    context "with invalid inputs" do
      it "does not submit the form" do
        fill_in "case-contact-duration-hours", with: "0"
        fill_in "case-contact-duration-minutes", with: "5"

        expect {
          click_on "Submit"
        }.not_to change(CaseContact, :count)
      end
    end
  end

  context "mutliple contact type groups" do
    let(:organization) { create(:casa_org) }
    let(:admin) { create(:casa_admin, casa_org: organization) }
    let(:casa_case) { create(:casa_case, casa_org: organization) }

    before do
      sign_in admin
    end

    it "should check the correct box when clicking the label" do
      group_1 = create(:contact_type_group, casa_org: organization)
      create(:contact_type, name: "School", contact_type_group: group_1)
      group_2 = create(:contact_type_group, casa_org: organization)
      create(:contact_type, name: "Parent", contact_type_group: group_2)

      visit new_case_contact_path(casa_case.id)

      expect { check "Parent" }.not_to raise_error
    end
  end

  context "volunteer user" do
    let(:organization) { create(:casa_org) }
    let!(:empty) { create(:contact_type_group, name: "Empty", casa_org: organization) }
    let!(:grp_with_hidden) { create(:contact_type_group, name: "OnlyHiddenTypes", casa_org: organization) }
    let!(:hidden_type) { create(:contact_type, name: "Hidden", active: false, contact_type_group: grp_with_hidden) }

    it "is successful", js: true do
      volunteer = create(:volunteer, :with_casa_cases)
      volunteer_casa_case_one = volunteer.casa_cases.first
      create_contact_types(volunteer_casa_case_one.casa_org)

      sign_in volunteer

      visit new_case_contact_path(volunteer_casa_case_one.id)

      check volunteer_casa_case_one.case_number
      check "School"
      check "Therapist"
      choose "Yes"
      select "In Person", from: "Contact medium"
      fill_in "case-contact-duration-hours", with: "1"
      fill_in "case-contact-duration-minutes", with: "45"
      fill_in "Occurred at", with: "04/04/2020"
      fill_in "Miles driven", with: "30"
      select "Yes", from: "Want driving reimbursement"
      fill_in "Notes", with: "Hello world"

      expect(page).not_to have_text("error")
      expect(page).to_not have_text("Empty")
      expect(page).to_not have_text("Hidden")

      click_on "Submit"
      expect(page).to have_text("Confirm Note Content")
      expect {
        click_on "Continue Submitting"
      }.to change(CaseContact, :count).by(1)

      expect(volunteer_casa_case_one.case_contacts.length).to eq(1)
      case_contact = volunteer_casa_case_one.case_contacts.first
      expect(case_contact.casa_case_id).to eq volunteer_casa_case_one.id
      expect(case_contact.contact_types.map(&:name)).to include "School"
      expect(case_contact.contact_types.map(&:name)).to include "Therapist"
      expect(case_contact.duration_minutes).to eq 105
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
      choose "Yes"
      select "In Person", from: "Contact medium"
      fill_in "case-contact-duration-hours", with: "1"
      fill_in "case-contact-duration-minutes", with: "45"
      fill_in "Occurred at", with: "04/04/2020"
      fill_in "Miles driven", with: "30"
      select "Yes", from: "Want driving reimbursement"
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
      choose "Yes"
      select "In Person", from: "Contact medium"
      fill_in "case-contact-duration-hours", with: "1"
      fill_in "case-contact-duration-minutes", with: "45"
      fill_in "Occurred at", with: "04/04/2020"
      fill_in "Miles driven", with: "30"
      select "Yes", from: "Want driving reimbursement"
      fill_in "Notes", with: "This is the note"

      expect(page).not_to have_text("error")
      click_on "Submit"
      expect(page).to have_text("Confirm Note Content")
      expect {
        click_on "Continue Submitting"
      }.to change(CaseContact, :count).by(1)

      expect(CaseContact.first.notes).to eq "This is the note"
    end

    it "does not submit the form when note is added but not confirmed" do
      volunteer = create(:volunteer, :with_casa_cases)
      volunteer_casa_case_one = volunteer.casa_cases.first
      create_contact_types(volunteer_casa_case_one.casa_org)

      sign_in volunteer

      visit new_case_contact_path

      check volunteer_casa_case_one.case_number
      check "School"
      check "Therapist"
      choose "Yes"
      select "In Person", from: "Contact medium"
      fill_in "case-contact-duration-hours", with: "1"
      fill_in "case-contact-duration-minutes", with: "45"
      fill_in "Occurred at", with: "04/04/2020"
      fill_in "Miles driven", with: "30"
      select "Yes", from: "Want driving reimbursement"
      fill_in "Notes", with: "This is the note"

      expect(page).not_to have_text("error")
      click_on "Submit"
      expect(page).to have_text("Confirm Note Content")
      expect {
        click_on "Go Back to Form"
      }.not_to change(CaseContact, :count)
    end

    context "with invalid inputs" do
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
        choose "Yes"
        select "In Person", from: "Contact medium"
        fill_in "case-contact-duration-hours", with: "1"
        fill_in "case-contact-duration-minutes", with: "45"
        # Future date: invalid

        alert_msg = page.accept_alert do
          fill_in "Occurred at", with: future_date.strftime("%Y/%m/%d\n")
        end
        expect(alert_msg).to eq("Case Contact Occurrences cannot be in the future.") # js validation

        fill_in "Occurred at", with: 2.days.ago.strftime("%Y/%m/%d\n")

        fill_in "Miles driven", with: "0"
        select "Yes", from: "Want driving reimbursement"
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
        expect(page).to have_select("Contact medium", selected: "In Person")
        expect(page).to have_field("case-contact-duration-hours", with: "1")
        expect(page).to have_field("case-contact-duration-minutes", with: "45")
        expect(page).to have_field("Occurred at", with: 2.days.ago.strftime("%Y-%m-%d"))
        expect(page).to have_field("Miles driven", with: "0")
        expect(page).to have_select("Want driving reimbursement", selected: "Yes")
        expect(page).to have_field("Notes", with: "Hello world")
      end
    end

    context "with contact made not checked" do
      it "does not re-render form, preserves all previously entered selections", js: true do
        volunteer = create(:volunteer, :with_casa_cases)
        volunteer_casa_case_one = volunteer.casa_cases.first
        create_contact_types(volunteer_casa_case_one.casa_org)

        sign_in volunteer

        visit new_case_contact_path

        check volunteer_casa_case_one.case_number
        check "School"
        check "Therapist"
        select "In Person", from: "Contact medium"
        fill_in "case-contact-duration-hours", with: "1"
        fill_in "case-contact-duration-minutes", with: "45"
        # Future date: invalid
        fill_in "Occurred at", with: 2.days.ago.strftime("%Y-%m-%d")
        fill_in "Miles driven", with: "0"
        select "Yes", from: "Want driving reimbursement"
        fill_in "Notes", with: "Hello world"

        expect {
          click_on "Submit"
        }.not_to change(CaseContact, :count)

        expect(page).not_to have_text("Must enter miles driven to receive driving reimbursement.")
        expect(page).to have_checked_field(volunteer_casa_case_one.case_number)
        expect(page).to have_unchecked_field("Attorney")
        expect(page).to have_checked_field("School")
        expect(page).to have_checked_field("Therapist")
        expect(page).not_to have_checked_field("Yes")
        expect(page).not_to have_checked_field("No")
        expect(page).to have_select("Contact medium", selected: "In Person")
        expect(page).to have_field("case-contact-duration-hours", with: "1")
        expect(page).to have_field("case-contact-duration-minutes", with: "45")
        expect(page).to have_field("Occurred at", with: 2.days.ago.strftime("%Y/%m/%d"))
        expect(page).to have_field("Miles driven", with: "0")
        expect(page).to have_select("Want driving reimbursement", selected: "Yes")
        expect(page).to have_field("Notes", with: "Hello world")
      end
    end

    context "with no contact types set for the volunteer's cases" do
      it "renders all of the org's contact types", js: true do
        org = create(:casa_org)
        create_contact_types(org)
        volunteer = create(:volunteer, :with_casa_cases, casa_org: org)

        sign_in volunteer

        visit new_case_contact_path

        expect(page).to have_field("Attorney")
        expect(page).to have_field("School")
        expect(page).to have_field("Therapist")
      end
    end

    context "with specific contact types allowed for the volunteer's cases" do
      it "only renders contact types that are allowed for the volunteer's cases", js: true do
        org = create(:casa_org)
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
