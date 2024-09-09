require "rails_helper"

RSpec.describe "case_contacts/create", :js, type: :system do
  let(:contact_topics) { [build(:contact_topic, question: "q1"), build(:contact_topic, question: "q2")] }
  let(:org) { create(:casa_org, contact_topics: contact_topics) }
  let(:volunteer) { create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor, casa_org: org) }
  let(:casa_case) { volunteer.casa_cases.first }

  before do
    # TODO make sure this is right...
    allow(Flipper).to receive(:enabled?).with(:reimbursement_warning, org).and_return(true)
    allow(Flipper).to receive(:enabled?).with(:show_additional_expenses).and_return(true)
    allow(org).to receive(:show_driving_reimbursement).and_return(true)

    sign_in volunteer
  end

  describe "redirects to where new case contact started from" do
    # These could be request specs? request with params, redirect to the proper page...
    it "when /case_contacts" do
      visit case_contacts_path

      click_on "New Case Contact"
      complete_details_page(case_numbers: [casa_case.case_number], medium: "In Person", contact_made: true, hours: 1, minutes: 45)
      complete_notes_page
      fill_in_expenses_page
      click_on "Submit"

      expect(page).to have_text "Case contact successfully created"
      pending "Something unique to case show page"
      expect(page).to have_text "Something unique to case show page"
    end

    it "when /case_contacts?casa_case_id=ID" do
      visit case_contacts_path(casa_case_id: casa_case.id)

      click_on "New Case Contact"
      complete_details_page(case_numbers: [casa_case.case_number], medium: "In Person", contact_made: true, hours: 1, minutes: 45)
      complete_notes_page
      fill_in_expenses_page
      click_on "Submit"

      expect(page).to have_text "Case contact successfully created"
      pending "Something unique to redirected page"
      expect(page).to have_text "Something unique to redirected page"
    end

    it "when /casa_cases/CASE_NUMBER" do
      visit casa_case_path(casa_case)

      click_on "New Case Contact"
      complete_details_page(case_numbers: [casa_case.case_number], medium: "In Person", contact_made: true, hours: 1, minutes: 45)
      complete_notes_page
      fill_in_expenses_page
      click_on "Submit"

      expect(page).to have_text "Case contact successfully created"
      pending "Something unique to redirected page"
      expect(page).to have_text "Something unique to redirected page"
    end
  end

  describe "notes page", :js, pending: "These are assertions about case show page, test them there." do
    before do
      visit new_case_contact_path

      complete_details_page(
        case_numbers: [casa_case.case_number],
        contact_topics: [contact_topics.first.question]
      )
      complete_notes_page(contact_topic_answers: ["This is an answer."])
      click_on "Submit"
      expect(page).to have_text("Case Contacts")
    end

    it "has selected topics expanded but no details expanded" do
      topic_one_id = contact_topics.first.question.parameterize.underscore
      topic_two_id = contact_topics.last.question.parameterize.underscore

      expect(page).to have_text contact_topics.first.question
      expect(page).to have_no_text contact_topics.first.details

      within("##{topic_one_id}") do
        expect(page).to have_text("read more")
        expect(page).to have_css("##{topic_one_id} textarea")
      end

      expect(page).to have_text contact_topics.last.question
      expect(page).to have_no_text contact_topics.last.details
      expect(page).to have_no_css("##{topic_two_id}")
    end

    it "expands to show and hide the text field and details" do
      click_on "read more"
      topic_id = contact_topics.first.question.parameterize.underscore

      expect(page).to have_text(contact_topics.first.question)
      expect(page).to have_text(contact_topics.first.details)
      expect(page).to have_css("##{topic_id} textarea")

      find("##{topic_id}_button").click

      expect(page).to have_text(contact_topics.first.question)
      expect(page).to have_no_text(contact_topics.first.details)
      expect(page).to have_no_css("##{topic_id} textarea")

      find("##{topic_id}_button").click

      expect(page).to have_text(contact_topics.first.question)
      expect(page).to have_text(contact_topics.first.details)
      expect(page).to have_css("##{topic_id} textarea")
    end

    it "expands to show/hide details", :js do
      topic_id = contact_topics.first.question.parameterize.underscore

      expect(page).to have_text(contact_topics.first.question)

      within("##{topic_id}") do
        expect(page).to have_no_text(contact_topics.first.details)
        expect(page).to have_css("##{topic_id} textarea")

        click_on "read more"

        expect(page).to have_text(contact_topics.first.details)
        expect(page).to have_css("##{topic_id} textarea")

        click_on "read less"

        expect(page).to have_no_text(contact_topics.first.details)
        expect(page).to have_css("##{topic_id} textarea")
      end
    end
  end
end
