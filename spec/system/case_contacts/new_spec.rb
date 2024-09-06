require "rails_helper"
require "action_view"

RSpec.describe "case_contacts/new", type: :system, js: true do
  include ActionView::Helpers::SanitizeHelper

  let(:casa_org) { build :casa_org }
  let(:casa_case) { create :casa_case, :with_case_assignments, casa_org: }
  let(:case_number) { casa_case.case_number }
  let(:contact_type_group) { build :contact_type_group, casa_org: }
  let!(:school_contact_type) { create :contact_type, contact_type_group:, name: "School" }
  let!(:therapist_contact_type) { create :contact_type, contact_type_group:, name: "Therapist" }

  before { sign_in user }

  subject { visit new_case_contact_path casa_case }

  context "when admin" do
    let(:user) { create :casa_admin, casa_org: }

    it "does not display empty or hidden contact type groups; can create CaseContact" do
      build(:contact_type_group, name: "Empty", casa_org:)
      grp_with_hidden = build(:contact_type_group, name: "OnlyHiddenTypes", casa_org:)
      create(:contact_type, name: "Hidden", active: false, contact_type_group: grp_with_hidden)

      visit casa_case_path(casa_case)
      # assert to wait for page loading, to reduce flakiness
      expect(page).to have_text("CASA Case Details")
      # does not show empty contact type groups
      expect(page).to_not have_text("Empty")
      # does not show contact type groups with only hidden contact types
      expect(page).to_not have_text("Hidden")

      click_on "New Case Contact"
      complete_details_page(
        case_numbers: [], contact_types: %w[School Therapist], contact_made: true,
        medium: "Video", occurred_on: Date.new(2020, 4, 5), hours: 1, minutes: 45
      )
      complete_notes_page
      fill_in_expenses_page

      expect {
        click_on "Submit"
      }.to change(CaseContact.active, :count).by(1)
      contact = CaseContact.last
      expect(contact.casa_case_id).to eq casa_case.id
      expect(contact.contact_types.map(&:name)).to include("School", "Therapist")
      expect(contact.duration_minutes).to eq 105
    end
  end

  context "volunteer user" do
    let(:volunteer) { create :volunteer, :with_single_case, casa_org: }
    let(:user) { volunteer }
    let(:casa_case) { volunteer.casa_cases.first }

    it "saves entered details" do
      subject

      complete_details_page(
        case_numbers: [case_number], contact_types: %w[School Therapist], contact_made: true,
        medium: "In Person", occurred_on: Date.today, hours: 1, minutes: 45
      )
      complete_notes_page(notes: "Hello world")
      fill_in_expenses_page(miles: 50, want_reimbursement: true, address: "123 Example St")
      expect {
        click_on "Submit"
      }.to change { CaseContact.where(status: "active").count }.by(1)

      case_contact = casa_case.case_contacts.last
      aggregate_failures do
        # associations
        expect(case_contact.casa_case).to eq casa_case
        expect(case_contact.creator).to eq user
        expect(case_contact.contact_types.map(&:name)).to include("School", "Therapist")
        # entered details
        expect(case_contact.duration_minutes).to eq 105
        expect(case_contact.contact_made).to be true
        expect(case_contact.medium_type).to eq "in-person"
        expect(case_contact.want_driving_reimbursement).to be true
        expect(case_contact.miles_driven).to eq 50
        expect(case_contact.draft_case_ids).to eq [casa_case.id]
        expect(case_contact.volunteer_address).to eq "123 Example St"
        expect(case_contact.occurred_at).to eq Date.today
        expect(case_contact.notes).to eq "Hello world"
        # other fields
        expect(case_contact.reimbursement_complete).to be false
        expect(case_contact.status).to eq "active"
        expect(case_contact.metadata).to be_present
      end
    end

    it "is successful without 'miles_driven' or 'want_driving_reimbursement'" do
      subject

      complete_details_page(
        case_numbers: [case_number], contact_types: %w[School Therapist], contact_made: true,
        medium: "In Person", occurred_on: Date.new(2020, 0o4, 0o6), hours: 1, minutes: 45
      )
      complete_notes_page(notes: "Hello world")
      fill_in_expenses_page
      expect { click_on "Submit" }.to change { CaseContact.where(status: "active").count }.by(1)

      case_contact = casa_case.case_contacts.last
      expect(case_contact.casa_case_id).to eq casa_case.id
      expect(case_contact.contact_types.map(&:name)).to include("School", "Therapist")
      expect(case_contact.duration_minutes).to eq 105
    end

    it "autosaves notes" do
      subject

      complete_details_page(
        case_numbers: [case_number], contact_types: %w[School Therapist], contact_made: true,
        medium: "In Person", occurred_on: "04/04/2020", hours: 1, minutes: 45
      )
      expect(CaseContact.last.notes).not_to eq "Hello world"

      complete_notes_page(notes: "Hello world", click_continue: false)

      within 'div[data-controller="autosave"]' do
        find('small[data-autosave-target="alert"]', text: "Saved!")
      end

      expect(CaseContact.last.notes).to eq "Hello world"
    end

    it "submits the form when no note was added" do
      subject

      complete_details_page(
        case_numbers: [case_number], contact_types: %w[School Therapist], contact_made: true,
        medium: "In Person", occurred_on: "04/04/2020", hours: 1, minutes: 45
      )
      complete_notes_page(notes: "")
      fill_in_expenses_page

      expect {
        click_on "Submit"
      }.to change(CaseContact.active, :count).by(1)

      expect(CaseContact.first.notes).to eq ""
    end

    it "submits the form when note is added" do
      subject

      complete_details_page(
        case_numbers: [case_number], contact_types: %w[School Therapist], contact_made: true,
        medium: "In Person", occurred_on: "04/04/2020", hours: 1, minutes: 45
      )
      complete_notes_page(notes: "This is the note")
      fill_in_expenses_page

      expect {
        click_on "Submit"
      }.to change(CaseContact.active, :count).by(1)

      expect(CaseContact.first.notes).to eq "This is the note"
    end

    context "with invalid inputs" do
      it "re-renders the form with errors, but preserving all previously entered selections" do
        subject
        complete_details_page(
          case_numbers: [case_number], contact_types: %w[School], contact_made: true, medium: nil,
          occurred_on: "04/04/2020", hours: 1, minutes: 45
        )
        expect(page).to have_text("Medium type can't be blank")

        choose_medium("In Person")
        complete_notes_page
        fill_in_expenses_page(want_reimbursement: true)
        click_on "Submit"
        expect(page).to have_text("Must enter miles driven to receive driving reimbursement.")
      end
    end

    context "with no contact types set for the volunteer's cases" do
      before { expect(casa_case.contact_types).to be_empty }

      it "renders all of the org's contact types" do
        subject

        find("#case_contact_contact_type_ids-ts-control").click
        expect(page).to have_text("School")
        expect(page).to have_text("Therapist")
      end
    end

    context "with specific contact types allowed for the volunteer's cases" do
      let!(:attorney_contact_type) { create :contact_type, contact_type_group:, name: "Attorney" }

      before { casa_case.update!(contact_types: [school_contact_type, therapist_contact_type]) }

      it "only renders contact types that are allowed for the volunteer's cases" do
        expect(casa_org.contact_types.map(&:name)).to include("Attorney")
        subject

        within find("#contact-type-id-selector") do
          find(".ts-control").click
        end

        expect(page).not_to have_text("Attorney")
        expect(page).to have_text("School")
        expect(page).to have_text("Therapist")
      end
    end

    context "when driving reimbursement is hidden by the CASA org" do
      let(:casa_org) { build(:casa_org, show_driving_reimbursement: false) }

      it "skips reimbursement (step 3)" do
        subject

        complete_details_page(
          case_numbers: [case_number], contact_types: %w[School], contact_made: true, medium: "In Person"
        )
        complete_notes_page(click_continue: false)
        expect(page).to have_text("Step 2 of 2")
        click_on "Submit"
        expect(page).to have_text("Case contact successfully created")
      end
    end

    context "when driving reimbursement is hidden when volunteer not allowed to request" do
      let(:casa_org) { build(:casa_org, show_driving_reimbursement: true) }
      let(:volunteer) { create(:volunteer, :with_disasllow_reimbursement, casa_org:) }

      it "does not show for case_contacts" do
        subject

        complete_details_page(case_numbers: [case_number], contact_types: %w[School], contact_made: true, medium: "In Person")
        complete_notes_page

        expect(page).not_to have_field("b. Want Driving Reimbursement")
      end
    end

    context "when 'Create Another' is checked" do
      it "redirects to the new CaseContact form with the same case selected" do
        subject
        complete_details_page(
          case_numbers: [case_number], contact_types: %w[School Therapist], contact_made: true,
          medium: "In Person", occurred_on: Date.today, hours: 1, minutes: 45
        )
        complete_notes_page(notes: "Hello world")

        check "Create Another"
        submitted_case_contact = CaseContact.last
        expect { click_on "Submit" }.to change { CaseContact.count }.by(1)
        next_case_contact = CaseContact.last

        expect(page).to have_text "Step 1 of 3"
        # store that the submitted contact used 'create another' in metadata
        expect(submitted_case_contact.reload.metadata["create_another"]).to be true
        # new contact uses draft_case_ids from the original & form selects them
        expect(next_case_contact.draft_case_ids).to eq [casa_case.id]
        expect(page).to have_text case_number
        # default values for other attributes (not from the last contact)
        expect(next_case_contact.status).to eq "started"
        expect(next_case_contact.miles_driven).to be_zero
        %i[casa_case_id duration_minutes occurred_at medium_type
          want_driving_reimbursement notes].each do |attribute|
          expect(next_case_contact.send(attribute)).to be_blank
        end
        expect(next_case_contact.contact_made).to be true
      end

      it "does not reset referring location" do
        visit casa_case_path casa_case
        # referrer will be set by CaseContactsController#new to casa_case_path(casa_case)
        click_on "New Case Contact"
        complete_details_page contact_made: true, medium: "In Person"
        complete_notes_page

        # goes through CaseContactsController#new, but should not set a referring location
        check "Create Another"
        click_on "Submit"

        complete_details_page contact_made: true, medium: "In Person"
        complete_notes_page

        click_on "Submit"
        # update should redirect to the original referrer, casa_case_path(casa_case)
        expect(page).to have_text "CASA Case Details"
        expect(page).to have_text "Case number: #{case_number}"
      end

      context "multiple cases selected" do
        let(:volunteer) { create(:volunteer, :with_casa_cases, casa_org:) }
        let(:casa_case_two) { volunteer.casa_cases.second }
        let(:case_number_two) { casa_case_two.case_number }

        it "redirects to the new CaseContact form with the same cases selected" do
          subject
          complete_details_page(
            case_numbers: [case_number, case_number_two], contact_made: true, medium: "In Person"
          )
          complete_notes_page
          check "Create Another"
          click_on "Submit"
          expect(page).to have_text "Step 1 of 3"
          next_case_contact = CaseContact.last
          expect(next_case_contact.draft_case_ids).to match_array [casa_case.id, casa_case_two.id]
          expect(page).to have_text case_number
          expect(page).to have_text case_number_two
        end
      end
    end

    describe "differences in single vs. multiple cases" do
      let(:first_case) { volunteer.casa_cases.first }

      context "multiple cases" do
        let(:volunteer) { create(:volunteer, :with_casa_cases, casa_org:) }
        let(:second_case) { volunteer.casa_cases.second }

        context "case default selection" do
          it "selects no cases" do
            subject

            expect(page).not_to have_text(first_case.case_number)
            expect(page).not_to have_text(second_case.case_number)
          end

          it "warns user about using the back button on step 1" do
            subject

            click_on "Back"
            expect(page).to have_selector("h2", text: "Discard draft?")
          end

          context "when there are params defined" do
            it "select the cases defined in the params" do
              visit new_case_contact_path(case_contact: {casa_case_id: first_case.id})

              expect(page).to have_text(first_case.case_number)
              expect(page).not_to have_text(second_case.case_number)
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
          subject

          expect(page).to have_text(first_case.case_number)
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
end
