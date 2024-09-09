require "rails_helper"
require "action_view"

RSpec.describe "case_contacts/new", :js, type: :system do
  let(:casa_org) { create :casa_org }
  let(:contact_type_group) { create :contact_type_group, casa_org: }
  let!(:school_contact_type) { create :contact_type, contact_type_group:, name: "School" }

  let(:volunteer) { create :volunteer, :with_single_case, casa_org: }
  let(:supervisor) { create :supervisor, casa_org:, volunteers: [volunteer] }
  let(:casa_admin) { create :casa_admin, casa_org: }
  let(:casa_case) { volunteer.casa_cases.first }
  let(:case_number) { casa_case.case_number }

  let(:user) { volunteer }

  before { sign_in user }

  subject { visit new_case_contact_path casa_case }

  it "page load creates a case_contact with status: 'started' & draft_case_ids: [casa_case.id]" do
    expect { subject }.to change(CaseContact.started, :count).by(1)
    case_contact = CaseContact.started.last
    expect(case_contact.draft_case_ids).to contain_exactly(casa_case.id)
    expect(case_contact.casa_case_id).to be_nil
  end

  it "saves entered details and updates status to 'active'" do
    subject

    expect(page).to have_text "New Case Contact"
    case_contact = CaseContact.started.last

    complete_details_page(
      case_numbers: [case_number], contact_types: %w[School], contact_made: true,
      medium: "In Person", occurred_on: Time.zone.yesterday, hours: 1, minutes: 45
    )
    click_on "Submit"
    expect(page).to have_text "Case contact successfully created."

    case_contact.reload
    aggregate_failures do
      expect(case_contact.status).to eq "active"
      # entered details
      expect(case_contact.draft_case_ids).to eq [casa_case.id]
      expect(case_contact.occurred_at).to eq Time.zone.yesterday
      expect(case_contact.contact_types.map(&:name)).to contain_exactly("School")
      expect(case_contact.medium_type).to eq "in-person"
      expect(case_contact.contact_made).to be true
      expect(case_contact.duration_minutes).to eq 105
      # skipped fields
      expect(case_contact.want_driving_reimbursement).to be false
      expect(case_contact.miles_driven).to be_zero
      expect(case_contact.volunteer_address).to be_empty
      expect(case_contact.notes).to be_nil
      # associations
      expect(case_contact.casa_case).to eq casa_case
      expect(case_contact.creator).to eq volunteer
      # other attributes
      expect(case_contact.reimbursement_complete).to be false
      expect(case_contact.status).to eq "active"
      expect(case_contact.metadata).to be_present
    end
  end

  context "with invalid inputs" do
    it "re-renders the form with errors, preserving all previously entered selections" do
      subject
      complete_details_page(
        case_numbers: [], contact_types: %w[School], contact_made: true, medium: nil,
        hours: 1, minutes: 45, occurred_on: ""
      )

      expect { click_on "Submit" }.not_to change(CaseContact, :count)

      expect(page).to have_text("Date can't be blank")
      expect(page).to have_text("Medium type can't be blank")

      expect(page).to have_field("case_contact_duration_hours", with: 1)
      expect(page).to have_field("case_contact_duration_minutes", with: 45)
      expect(page).to have_field("case_contact_contact_made", with: "1")
      expect(page).to have_field(class: "contact-form-type-checkbox", with: school_contact_type.id, checked: true)
    end
  end

  describe "contact types" do
    it "requires at lease one contact type",
      pending: "TODO: (I think) this is a new feature/validation to implement" do
      subject

      fill_in_contact_details(contact_types: [])

      expect { click_on "Submit" }.not_to change(CaseContact, :count)

      expect(page).to have_text "New Case Contact"
      expect(page).to have_text("You must select at least one contact type")
    end

    it "does not display empty contact groups or hidden contact types" do
      create(:contact_type, name: "Shown Checkbox", contact_type_group:)
      create(:contact_type_group, name: "Empty Group", casa_org:)
      grp_with_hidden = build(:contact_type_group, name: "OnlyHiddenTypes", casa_org:)
      create(:contact_type, name: "Hidden", active: false, contact_type_group: grp_with_hidden)

      subject

      expect(page).to have_text(contact_type_group.name)
      expect(page).to have_no_text("OnlyHiddenTypes")
      expect(page).to have_no_text("Empty Group")

      expect(page).to have_field(class: "contact-form-type-checkbox", count: 2)
      expect(page).to have_field("School", class: "contact-form-type-checkbox")
      expect(page).to have_field("Shown Checkbox", class: "contact-form-type-checkbox")
      expect(page).to have_no_text("Empty")
      expect(page).to have_no_text("Hidden")
    end

    context "when the case has case contact types assigned" do
      let!(:casa_case) { create(:casa_case, :with_casa_case_contact_types, :with_one_case_assignment, casa_org:) }
      let(:volunteer) { casa_case.volunteers.first }
      let(:casa_case_contact_types) { casa_case.contact_types }

      it "shows only the casa case's contact types" do
        therapist_contact_type = create :contact_type, contact_type_group:, name: "Therapist"
        expect(casa_org.contact_types).to contain_exactly(school_contact_type, therapist_contact_type, *casa_case_contact_types)
        expect(casa_case_contact_types).not_to include([school_contact_type, therapist_contact_type])

        subject

        expect(page).to have_field(class: "contact-form-type-checkbox", with: casa_case_contact_types.first.id)
        expect(page).to have_field(class: "contact-form-type-checkbox", with: casa_case_contact_types.last.id)
        expect(page).to have_field(class: "contact-form-type-checkbox", count: casa_case_contact_types.size) # (no others)
      end
    end
  end

  describe "notes/contact topic answsers section" do
    let(:contact_topics) do
      [
        create(:contact_topic, casa_org:, question: "Active Topic", active: true, soft_delete: false),
        create(:contact_topic, casa_org:, question: "Inactive Not Soft Deleted", active: false, soft_delete: false),
        create(:contact_topic, casa_org:, question: "Active Soft Deleted", active: true, soft_delete: true),
        create(:contact_topic, casa_org:, question: "Inactive Soft Deleted", active: false, soft_delete: true)
      ]
    end

    it "does not show topic questions that are inactive or soft deleted in select" do
      contact_topics
      subject
      click_on "Add Note"

      expect(page).to have_select(class: "contact-topic-id-select", options: ["Active Topic"])
      expect(page).to have_no_text("Inactive Not Soft Deleted")
      expect(page).to have_no_text("Active Soft Deleted")
      expect(page).to have_no_text("Inactive Soft Deleted")
    end

    it "autosaves notes & answers",
      pending: "TODO: reimplement autosave" do
      contact_topics
      expect { subject }.to change(CaseContact.started, :count).by(1)
      case_contact = CaseContact.started.last
      expect(case_contact.contact_topic_answers).to be_empty

      complete_details_page(
        case_numbers: [case_number], contact_types: %w[School], contact_made: true,
        medium: "In Person", occurred_on: "04/04/2020", hours: 1, minutes: 45
      )

      click_on "Add Note"
      answer_topic "Active Topic", "Hello world"

      within 'div[data-controller="autosave"]' do
        find('small[data-autosave-target="alert"]', text: "Saved!")
      end

      expect(case_contact.reload.contact_topic_answers.first.value).to eq "Hello world"
    end

    context "when org has no contact topics" do
      it "allows entering contact notes as 'Additional Notes'" do
        expect(casa_org.contact_topics.size).to eq 0
        subject

        fill_in_contact_details contact_types: %w[School]

        click_on "Add Note"
        find(".contact-topic-id-select").select("Additional Notes")
        find(".contact-topic-answer-input").fill_in(with: "This is the note")

        expect {
          click_on "Submit"
        }.to change(CaseContact.active, :count).by(1)

        case_contact = CaseContact.active.last
        expect(case_contact.contact_topic_answers).to be_empty
        expect(case_contact.notes).to eq "This is the note"
      end

      it "guides volunteer to contact admin" do
        expect(casa_org.contact_topics.size).to eq 0
        subject

        expect(page).to have_text("Your organization has not set any Court Report Topics yet. Contact your admin to learn more.")
      end

      context "with admin user" do
        let(:user) { casa_admin }

        it "shows the admin the contact topics link" do
          expect(casa_org.contact_topics.size).to eq 0
          subject

          expect(page).to have_link("Manage Case Contact Topics")
        end
      end

      context "with supervisor user" do
        let(:user) { supervisor }

        it "guides supervisor to contact admin" do
          expect(casa_org.contact_topics.size).to eq 0
          subject

          expect(page).to have_text("Your organization has not set any Court Report Topics yet. Contact your admin to learn more.")
        end
      end
    end
  end

  describe "reimbursement section" do
    let(:casa_org) { build(:casa_org, :all_reimbursements_enabled) }

    let(:reimbursement_section_id) { "#contact-form-reimbursement" }
    let(:reimbursement_checkbox) { "case_contact_want_driving_reimbursement" }
    let(:miles_driven_input) { "case_contact_miles_driven" }
    let(:volunteer_address_input) { "case_contact_volunteer_address" }
    let(:add_expense_button_text) { "Add Expense" }
    let(:expense_amount_class) { "expense-amount-input" }
    let(:expense_describe_class) { "expense-describe-input" }

    before do
      allow(Flipper).to receive(:enabled?).with(:show_additional_expenses).and_return(true)
      allow(Flipper).to receive(:enabled?).with(:reimbursement_warning, casa_org).and_call_original
    end

    it "is not shown until 'Request travel or other reimbursement' is checked",
      pending: "TODO: implement stimulus controller" do
      subject

      expect(page).to have_no_field(miles_driven_input)
      expect(page).to have_no_field(volunteer_address_input)
      expect(page).to have_no_button(add_expense_button_text)

      check reimbursement_checkbox

      expect(page).to have_field(miles_driven_input)
      expect(page).to have_field(volunteer_address_input)
      expect(page).to have_button(add_expense_button_text)
    end

    it "clears mileage info if reimbursement unchecked",
      pending: "TODO: implement stimulus controller" do
      subject
      fill_in_contact_details

      check reimbursement_checkbox
      fill_in miles_driven_input, with: 50
      fill_in volunteer_address_input, with: "123 Example St"
      uncheck reimbursement_checkbox

      expect { click_on "Submit" }.to change(CaseContact.active, :count).by(1)
      case_contact = CaseContact.active.last

      expect(case_contact.want_driving_reimbursement).to be false
      expect(case_contact.volunteer_address).to be_blank
      expect(case_contact.miles_driven).to be_zero
    end

    it "saves mileage and address information" do
      subject
      complete_details_page

      check reimbursement_checkbox

      fill_in miles_driven_input, with: 50
      fill_in volunteer_address_input, with: "123 Example St"

      expect { click_on "Submit" }.to change(CaseContact.active, :count).by(1)
      case_contact = CaseContact.active.last

      expect(case_contact.want_driving_reimbursement).to be true
      expect(case_contact.volunteer_address).to eq "123 Example St"
      expect(case_contact.miles_driven).to eq 50
    end

    it "does not accept decimal mileage" do
      subject
      complete_details_page

      check reimbursement_checkbox

      fill_in miles_driven_input, with: 50.5
      fill_in volunteer_address_input, with: "123 Example St"

      expect { click_on "Submit" }.not_to change(CaseContact.active, :count)
    end

    it "requires inputs if checkbox checked" do
      subject
      complete_details_page

      check reimbursement_checkbox

      expect { click_on "Submit" }.not_to change(CaseContact.active, :count)
      expect(page).to have_text("Must enter a valid mailing address for the reimbursement")
      expect(page).to have_text("Must enter miles driven to receive driving reimbursement")
    end

    context "when volunteer case assignment reimbursement is false" do
      let(:volunteer) { create :volunteer, :with_disallow_reimbursement, casa_org: }
      let(:casa_case) { volunteer.casa_cases.last }

      it "does not show reimbursement section" do
        subject

        expect(page).to have_no_button(add_expense_button_text)
        expect(page).to have_no_field(miles_driven_input)
        expect(page).to have_no_field(volunteer_address_input)
        expect(page).to have_no_field(reimbursement_checkbox)
        expect(page).to have_no_selector(reimbursement_section_id)
        expect(page).to have_no_text("reimbursement")
      end
    end

    context "when casa org driving reimbursement false, additional expenses true" do
      before { casa_org.update! show_driving_reimbursement: false }

      it "does not render the reimbursement section" do
        subject

        expect(page).to have_no_field(reimbursement_checkbox, visible: :all)
        expect(page).to have_no_field(miles_driven_input, visible: :all)
        expect(page).to have_no_field(volunteer_address_input, visible: :all)
        expect(page).to have_no_button(add_expense_button_text, visible: :all)
        expect(page).to have_no_field(class: "expense-amount-input")
        expect(page).to have_no_field(class: "expense-describe-input")
        expect(page).to have_no_text("reimbursement")
      end
    end

    context "when casa org additional expenses false" do
      before { casa_org.update! additional_expenses_enabled: false }

      it "enables mileage reimbursement but does shows additional expenses" do
        subject

        complete_details_page(case_numbers: [case_number], contact_types: %w[School])

        check reimbursement_checkbox

        expect(page).to have_field(miles_driven_input)
        expect(page).to have_field(volunteer_address_input)

        expect(page).to have_no_button(add_expense_button_text)
        expect(page).to have_no_field(class: "expense-amount-input", visible: :all)
        expect(page).to have_no_field(class: "expense-describe-input", visible: :all)
      end
    end

    context "when casa org does not allow mileage or expense reimbursement" do
      let(:casa_org) { create :casa_org, show_driving_reimbursement: false, additional_expenses_enabled: false }

      it "does not show reimbursement section" do
        subject

        expect(page).to have_no_button(add_expense_button_text)
        expect(page).to have_no_field(miles_driven_input)
        expect(page).to have_no_field(volunteer_address_input)
        expect(page).to have_no_field(reimbursement_checkbox)
        expect(page).to have_no_selector(reimbursement_section_id)
        expect(page).to have_no_text("reimbursement")
      end
    end
  end

  context "when 'Create Another' is checked" do
    it "redirects to the new CaseContact form with the same case selected" do
      subject
      complete_details_page(
        case_numbers: [case_number], contact_types: %w[School], contact_made: true,
        medium: "In Person", occurred_on: Date.today, hours: 1, minutes: 45
      )

      check "Create Another"
      expect { click_on "Submit" }
        .to change(CaseContact, :count).by(1)
      # .to change(CaseContact.active, :count).by(1)
      # .and change(CaseContact.started, :count).by(1)
      submitted_case_contact = CaseContact.active.last
      next_case_contact = CaseContact.started.last

        expect(page).to have_text "New Case Contact"
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
      complete_details_page

      # goes through CaseContactsController#new, but should not set a referring location
      check "Create Another"
      click_on "Submit"

      complete_details_page

      click_on "Submit"
      # update should redirect to the original referrer, casa_case_path(casa_case)
      expect(page).to have_text "CASA Case Details"
      expect(page).to have_text "Case number: #{case_number}"
    end

    context "when multiple cases selected" do
      let(:volunteer) { create(:volunteer, :with_casa_cases, casa_org:) }
      let(:casa_case) { volunteer.casa_cases.first }
      let(:casa_case_two) { volunteer.casa_cases.second }
      let(:case_number_two) { casa_case_two.case_number }
      let(:draft_case_ids) { [casa_case.id, casa_case_two.id] }

      it "redirects to the new CaseContact form with the same cases selected",
        pending: "TODO: passes when run alone, fails when run with rest of file (ordered)" do
        expect { subject }.to change(CaseContact.started, :count).by(1)
        this_case_contact = CaseContact.started.last

        complete_details_page(
          case_numbers: [case_number, case_number_two], contact_types: %w[School]
        )

        check "Create Another"

        expect {
          click_on "Submit"
        }.to change(CaseContact.active, :count).by(2)

        expect(page).to have_text "New Case Contact"
        expect(this_case_contact.reload.status).to eq "active"
        next_case_contact = CaseContact.not_active.last
        expect(next_case_contact).to be_present

        expect(next_case_contact.status).to eq "started"
        expect(page).to have_text case_number

        expect(page).to have_text case_number_two
        expect(next_case_contact.draft_case_ids).to match_array draft_case_ids
      end
    end
  end

  context "when volunteer has multiple cases" do
    let(:volunteer) { create(:volunteer, :with_casa_cases, casa_org:) }
    let(:first_case) { volunteer.casa_cases.first }
    let(:second_case) { volunteer.casa_cases.second }

    describe "case default selection" do
      it "selects no cases" do
        subject

        expect(page).to have_no_text(first_case.case_number)
        expect(page).to have_no_text(second_case.case_number)
      end

      it "warns user about using the back button on step 1" do
        subject

        click_on "Back"
        expect(page).to have_css("h2", text: "Discard draft?")
      end

      context "when there are params defined" do
        it "select the cases defined in the params" do
          visit new_case_contact_path(case_contact: {casa_case_id: first_case.id})

          expect(page).to have_text(first_case.case_number)
          expect(page).to have_no_text(second_case.case_number)
        end

        it "does not warn user when clicking the back button" do
          visit new_case_contact_path(case_contact: {casa_case_id: first_case.id})

          click_on "Back"
          expect(page).to have_css("h1", text: "Case Contacts")
          expect(page).to have_css("a", text: "New Case Contact")
        end
      end
    end
  end

  context "when volunteer has one case" do
    let(:first_case) { volunteer.casa_cases.first }

    it "selects the only case" do
      expect(volunteer.casa_cases.size).to eq 1

      subject

      expect(page).to have_text(first_case.case_number)
    end

    it "does not warn user when clicking the back button" do
      expect(volunteer.casa_cases.size).to eq 1

      visit new_case_contact_path(case_contact: {casa_case_id: first_case.id})

      click_on "Back"
      expect(page).to have_css("h1", text: "Case Contacts")
      expect(page).to have_css("a", text: "New Case Contact")
    end
  end

  context "with admin user" do
    let(:user) { casa_admin }

    it "can create CaseContact" do
      subject

      complete_details_page(
        case_numbers: [], contact_types: %w[School], contact_made: true,
        medium: "Video", occurred_on: Date.new(2020, 4, 5), hours: 1, minutes: 45
      )

      expect {
        click_on "Submit"
      }.to change(CaseContact.active, :count).by(1)
      contact = CaseContact.active.last
      expect(contact.casa_case_id).to eq casa_case.id
      expect(contact.contact_types.map(&:name)).to include("School")
      expect(contact.duration_minutes).to eq 105
    end
  end
end
