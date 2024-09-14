require "rails_helper"

RSpec.describe "case_contacts/edit", :js, type: :system do
  let(:organization) { build(:casa_org) }
  let(:volunteer) { create(:volunteer, :with_single_case, casa_org: organization) }
  let(:casa_case) { volunteer.casa_cases.first }
  let(:case_contact) { create(:case_contact, duration_minutes: 105, casa_case: casa_case, creator: volunteer) }

  let(:user) { volunteer }

  before { sign_in user }

  context "when admin" do
    let(:admin) { create(:casa_admin, casa_org: organization) }
    let(:case_contact) { create(:case_contact, duration_minutes: 105, casa_case:, creator: admin) }

    let(:user) { admin }

    it "admin successfully edits case contact" do
      visit edit_case_contact_path(case_contact)

      complete_details_page(case_numbers: [], contact_types: [], contact_made: true, medium: "Letter")
      complete_notes_page
      fill_in_expenses_page

      click_on "Submit"

      case_contact.reload
      expect(page).to have_text "Case contact created at #{case_contact.created_at.strftime("%-I:%-M %p on %m-%e-%Y")}, was successfully updated."
      expect(case_contact.casa_case_id).to eq casa_case.id
      expect(case_contact.duration_minutes).to eq 105
      expect(case_contact.medium_type).to eq "letter"
      expect(case_contact.contact_made).to be true
    end

    it "admin successfully edits case contact with mileage reimbursement" do
      casa_case = create(:casa_case, :with_one_case_assignment, casa_org: organization)
      case_contact = create(:case_contact, duration_minutes: 105, casa_case: casa_case)

      visit edit_case_contact_path(case_contact)

      complete_details_page(case_numbers: [], contact_types: [], contact_made: true, medium: "In Person", hours: 1, minutes: 45, occurred_on: "04/04/2020")
      complete_notes_page
      fill_in_expenses_page(miles: 10, want_reimbursement: true, address: "123 str")

      click_on "Submit"
      case_contact.reload
      expect(page).to have_text "Case contact created at #{case_contact.created_at.strftime("%-I:%-M %p on %m-%e-%Y")}, was successfully updated."
      expect(case_contact.casa_case.volunteers[0].address.content).to eq "123 str"
      expect(case_contact.casa_case_id).to eq casa_case.id
      expect(case_contact.duration_minutes).to eq 105
      expect(case_contact.medium_type).to eq "in-person"
      expect(case_contact.contact_made).to be true
    end

    it "does not allow volunteer address edit for case contact with ambiguous volunteer" do
      create(:case_assignment, casa_case:, volunteer: create(:volunteer, casa_org: organization))
      expect(casa_case.volunteers).not_to include case_contact.creator
      expect(casa_case.volunteers.size).to be > 1

      visit edit_case_contact_path(case_contact)

      complete_details_page(case_numbers: [], contact_types: [], contact_made: true, medium: "In Person", hours: 1, minutes: 45, occurred_on: "04/04/2020")
      complete_notes_page

      expect(find_by_id("case_contact_volunteer_address").value)
        .to eq("There are two or more volunteers assigned to this case and you are trying to set the address for both of them. This is not currently possible.")

      click_on "Submit"
      expect(case_contact.reload.volunteer_address).to be_blank
    end

    context "when user is part of a different organization" do
      let(:other_organization) { build(:casa_org) }
      let(:admin) { create(:casa_admin, casa_org: other_organization) }

      it "fails across organizations", js: false do
        visit edit_case_contact_path(case_contact)
        expect(page).to have_current_path supervisors_path, ignore_query: true
      end
    end
  end

  it "is successful" do
    visit edit_case_contact_path(case_contact)

    complete_details_page(contact_made: true, medium: "Letter")
    complete_notes_page
    fill_in_expenses_page

    click_on "Submit"

    case_contact.reload
    expect(page).to have_text "Case contact created at #{case_contact.created_at.strftime("%-I:%-M %p on %m-%e-%Y")}, was successfully updated."
    expect(case_contact.casa_case_id).to eq casa_case.id
    expect(case_contact.duration_minutes).to eq 105
    expect(case_contact.medium_type).to eq "letter"
    expect(case_contact.contact_made).to be true
  end

  it "is successful with mileage reimbursement on" do
    visit edit_case_contact_path(case_contact)

    complete_details_page(contact_made: true, medium: "In Person", hours: 1, minutes: 45, occurred_on: "04/04/2020")
    complete_notes_page
    fill_in_expenses_page(miles: 10, want_reimbursement: true, address: "123 str")

    click_on "Submit"

    case_contact.reload
    volunteer.reload
    expect(page).to have_text "Case contact created at #{case_contact.created_at.strftime("%-I:%-M %p on %m-%e-%Y")}, was successfully updated."
    expect(volunteer.address.content).to eq "123 str"
    expect(case_contact.casa_case_id).to eq casa_case.id
    expect(case_contact.duration_minutes).to eq 105
    expect(case_contact.medium_type).to eq "in-person"
    expect(case_contact.contact_made).to be true
  end

  it "autosaves notes" do
    autosave_alert_div = "#contact-form-notes"
    autosave_alert_css = 'small[role="alert"]'
    autosave_alert_text = "Saved!"

    case_contact = create(:case_contact, duration_minutes: 105, casa_case: casa_case, creator: volunteer, notes: "Hello from the other side")
    visit edit_case_contact_path(case_contact)

    complete_details_page(contact_made: true)
    expect(case_contact.reload.notes).to eq "Hello from the other side"

    answer_topic "Additional Notes", "Hello world"
    within autosave_alert_div do
      find(autosave_alert_css, text: autosave_alert_text)
    end
    expect(case_contact.reload.notes).to eq "Hello world"
  end

  context "when 'Create Another' option is checked" do
    it "creates a duplicate case contact for the second contact" do
      case_contact_draft_ids = case_contact.draft_case_ids
      visit edit_case_contact_path(case_contact)

      check "Create Another"

      expect { click_on "Submit" }.to change(CaseContact.started, :count).by(1)
      new_case_contact = CaseContact.last
      expect(new_case_contact.draft_case_ids).to match_array(case_contact_draft_ids)
      expect(page).to have_text "New Case Contact"
      expect(page).to have_text casa_case.case_number
    end
  end
end
