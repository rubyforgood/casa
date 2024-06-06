require "rails_helper"
require "action_view"

RSpec.describe "case_contacts/new", type: :system, js: true do
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
      complete_details_page(case_numbers: [], contact_types: %w[School Therapist], contact_made: true, medium: "Video", occurred_on: Date.new(2020, 4, 5), hours: 1, minutes: 45)
      complete_notes_page
      fill_in_expenses_page

      expect {
        click_on "Submit"
      }.to change(CaseContact.where(status: "active"), :count).by(1)
      expect(CaseContact.first.casa_case_id).to eq casa_case.id
      expect(CaseContact.first.contact_types).to match_array([school, therapist])
      expect(CaseContact.first.duration_minutes).to eq 105
    end
  end

  context "volunteer user" do
    let(:volunteer) { create(:volunteer, :with_casa_cases) }
    let(:volunteer_casa_case_one) { volunteer.casa_cases.first }

    before(:each) do
      sign_in volunteer
    end

    it "is successful without a. Miles Driven or driving reimbursement", js: true do
      FeatureFlagService.enable!(FeatureFlagService::SHOW_ADDITIONAL_EXPENSES_FLAG)
      organization = build(:casa_org)
      build(:contact_type_group, name: "Empty", casa_org: organization)
      grp_with_hidden = build(:contact_type_group, name: "OnlyHiddenTypes", casa_org: organization)
      build(:contact_type, name: "Hidden", active: false, contact_type_group: grp_with_hidden)
      create_contact_types(volunteer_casa_case_one.casa_org)

      visit new_case_contact_path(volunteer_casa_case_one.id)

      complete_details_page(case_numbers: [volunteer_casa_case_one.case_number], contact_types: %w[School Therapist], contact_made: true, medium: "In Person", occurred_on: Date.new(2020, 0o4, 0o6), hours: 1, minutes: 45)
      complete_notes_page(notes: "Hello world")
      fill_in_expenses_page

      click_on "Submit"

      expect(volunteer_casa_case_one.case_contacts.length).to eq(1)
      case_contact = volunteer_casa_case_one.case_contacts.first
      expect(case_contact.casa_case_id).to eq volunteer_casa_case_one.id
      expect(case_contact.contact_types.map(&:name)).to include "School"
      expect(case_contact.contact_types.map(&:name)).to include "Therapist"
      expect(case_contact.duration_minutes).to eq 105
    end

    it "autosaves notes", js: true do
      create_contact_types(volunteer_casa_case_one.casa_org)

      visit new_case_contact_path(volunteer_casa_case_one.id)

      complete_details_page(case_numbers: [volunteer_casa_case_one.case_number], contact_types: %w[School Therapist], contact_made: true, medium: "In Person", occurred_on: "04/04/2020", hours: 1, minutes: 45)
      expect(CaseContact.last.notes).not_to eq "Hello world"

      complete_notes_page(notes: "Hello world", click_continue: false)

      within 'div[data-controller="autosave"]' do
        find('small[data-autosave-target="alert"]', text: "Saved!")
      end

      expect(CaseContact.last.notes).to eq "Hello world"
    end

    it "submits the form when no note was added", js: true do
      create_contact_types(volunteer_casa_case_one.casa_org)

      visit new_case_contact_path

      complete_details_page(case_numbers: [volunteer_casa_case_one.case_number], contact_types: %w[School Therapist], contact_made: true, medium: "In Person", occurred_on: "04/04/2020", hours: 1, minutes: 45)
      complete_notes_page(notes: "")
      fill_in_expenses_page

      expect {
        click_on "Submit"
      }.to change(CaseContact.where(status: "active"), :count).by(1)

      expect(CaseContact.first.notes).to eq ""
    end

    it "submits the form when note is added", js: true do
      create_contact_types(volunteer_casa_case_one.casa_org)

      visit new_case_contact_path

      complete_details_page(case_numbers: [volunteer_casa_case_one.case_number], contact_types: %w[School Therapist], contact_made: true, medium: "In Person", occurred_on: "04/04/2020", hours: 1, minutes: 45)
      complete_notes_page(notes: "This is the note")
      fill_in_expenses_page

      expect {
        click_on "Submit"
      }.to change(CaseContact.where(status: "active"), :count).by(1)

      expect(CaseContact.first.notes).to eq "This is the note"
    end

    context "with invalid inputs" do
      it "re-renders the form with errors, but preserving all previously entered selections", js: true do
        create_contact_types(volunteer_casa_case_one.casa_org)

        visit new_case_contact_path

        complete_details_page(case_numbers: [volunteer_casa_case_one.case_number], contact_types: %w[School], contact_made: true, medium: nil, occurred_on: "04/04/2020", hours: 1, minutes: 45)
        expect(page).to have_text("Medium type can't be blank")

        complete_details_page(case_numbers: [volunteer_casa_case_one.case_number], contact_types: %w[School], contact_made: true, medium: "In Person", occurred_on: "04/04/2020", hours: 1, minutes: 45)
        complete_notes_page
        fill_in_expenses_page(want_reimbursement: true)
        click_on "Submit"
        expect(page).to have_text("Must enter miles driven to receive driving reimbursement.")
      end
    end

    context "with no contact types set for the volunteer's cases" do
      let(:org) { build(:casa_org) }
      let(:volunteer) { create(:volunteer, :with_casa_cases, casa_org: org) }

      it "renders all of the org's contact types", js: true do
        create_contact_types(org)

        visit new_case_contact_path

        find("#case_contact_contact_type_ids-ts-control").click
        expect(page).to have_text("Attorney")
        expect(page).to have_text("School")
        expect(page).to have_text("Therapist")
      end
    end

    context "with specific contact types allowed for the volunteer's cases" do
      let(:org) { build(:casa_org) }
      let(:volunteer) { create(:volunteer, :with_casa_cases, casa_org: org) }

      it "only renders contact types that are allowed for the volunteer's cases", js: true do
        contact_type_group = create_contact_types(org)
        contact_types_for_cases = contact_type_group.contact_types.reject { |ct| ct.name == "Attorney" }
        assign_contact_types_to_cases(volunteer.casa_cases, contact_types_for_cases)

        visit new_case_contact_path

        find(".ts-control").click
        expect(page).not_to have_text("Attorney")
        expect(page).to have_text("School")
        expect(page).to have_text("Therapist")
      end
    end

    context "when driving reimbursement is hidden by the CASA org" do
      let(:org) { build(:casa_org, show_driving_reimbursement: false) }
      let(:volunteer) { create(:volunteer, :with_casa_cases, casa_org: org) }

      it "does not show for case_contacts" do
        contact_type_group = create_contact_types(org)
        contact_types_for_cases = contact_type_group.contact_types.reject { |ct| ct.name == "Attorney" }
        assign_contact_types_to_cases(volunteer.casa_cases, contact_types_for_cases)

        visit new_case_contact_path

        complete_details_page(case_numbers: [volunteer.casa_cases.first.case_number], contact_types: %w[School], contact_made: true, medium: "In Person")
        complete_notes_page

        expect(page).not_to have_field("b. Want Driving Reimbursement")
      end
    end

    context "when driving reimbursement is hidden when volunteer not allowed to request" do
      let(:org) { build(:casa_org, show_driving_reimbursement: true) }
      let(:volunteer) { create(:volunteer, :with_disasllow_reimbursement, casa_org: org) }

      it "does not show for case_contacts" do
        contact_type_group = create_contact_types(org)
        contact_types_for_cases = contact_type_group.contact_types.reject { |ct| ct.name == "Attorney" }
        assign_contact_types_to_cases(volunteer.casa_cases, contact_types_for_cases)

        visit new_case_contact_path

        complete_details_page(case_numbers: [volunteer.casa_cases.first.case_number], contact_types: %w[School], contact_made: true, medium: "In Person")
        complete_notes_page

        expect(page).not_to have_field("b. Want Driving Reimbursement")
      end
    end

    describe "differences in single vs. multiple cases" do
      let(:volunteer) { create(:volunteer, :with_casa_cases) }
      let(:first_case) { volunteer.casa_cases.first }

      before(:each) do
        sign_in volunteer
      end

      context "multiple cases" do
        let(:second_case) { volunteer.casa_cases.second }

        context "case default selection" do
          it "selects no cases" do
            visit new_case_contact_path

            expect(page).not_to have_checked_field(first_case.case_number)
            expect(page).not_to have_checked_field(second_case.case_number)
          end

          it "warns user about using the back button on step 1" do
            visit new_case_contact_path

            click_on "Back"
            expect(page).to have_selector("h2", text: "Discard draft?")
          end

          context "when there are params defined" do
            it "select the cases defined in the params" do
              visit new_case_contact_path(case_contact: {casa_case_id: first_case.id})

              expect(page).to have_checked_field(first_case.case_number)
              expect(page).not_to have_checked_field(second_case.case_number)
            end

            it "does not warn user when clicking the back button" do
              visit new_case_contact_path(case_contact: {casa_case_id: first_case.id})

              click_on "Back"
              expect(page).to have_selector("h1", text: "Case Contacts")
              expect(page).to have_selector("a", text: "New Case Contact")
            end
          end
        end
      end

      context "single case" do
        let(:volunteer) { create(:volunteer, :with_single_case) }

        it "selects the only case" do
          visit new_case_contact_path

          expect(page).to have_checked_field(first_case.case_number)
        end

        it "does not warn user when clicking the back button" do
          visit new_case_contact_path(case_contact: {casa_case_id: first_case.id})

          click_on "Back"
          expect(page).to have_selector("h1", text: "Case Contacts")
          expect(page).to have_selector("a", text: "New Case Contact")
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
