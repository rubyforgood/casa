require "rails_helper"

RSpec.describe "case_contacts/create", type: :system, js: true do
  let(:contact_topics) { [build(:contact_topic, question: "q1"), build(:contact_topic, question: "q2")] }
  let(:org) { create(:casa_org, contact_topics: contact_topics) }
  let(:volunteer) { create(:volunteer, :with_cases_and_contacts, :with_assigned_supervisor, casa_org: org) }
  let(:casa_case) { volunteer.casa_cases.first }

  context "redirects to where new case contact started from" do
    before do
      sign_in volunteer
    end

    it "when /case_contacts" do
      visit case_contacts_path

      click_on "New Case Contact"
      complete_details_page(case_numbers: [casa_case.case_number], medium: "In Person", contact_made: true, hours: 1, minutes: 45)
      complete_notes_page
      fill_in_expenses_page
      click_on "Submit"

      expect(page).to have_text "Case contact successfully created"
    end

    it "when /case_contacts?casa_case_id=ID" do
      visit case_contacts_path(casa_case_id: casa_case.id)

      click_on "New Case Contact"
      complete_details_page(case_numbers: [casa_case.case_number], medium: "In Person", contact_made: true, hours: 1, minutes: 45)
      complete_notes_page
      fill_in_expenses_page
      click_on "Submit"

      expect(page).to have_text "Case contact successfully created"
    end

    it "when /casa_cases/CASE_NUMBER" do
      visit casa_case_path(casa_case)

      click_on "New Case Contact"
      complete_details_page(case_numbers: [casa_case.case_number], medium: "In Person", contact_made: true, hours: 1, minutes: 45)
      complete_notes_page
      fill_in_expenses_page
      click_on "Submit"

      expect(page).to have_text "Case contact successfully created"
    end
  end

  describe "notes page", js: true do
    before(:each) do
      sign_in volunteer
      visit case_contacts_path
      click_on "New Case Contact"

      complete_details_page(
        case_numbers: [casa_case.case_number],
        medium: "In Person",
        contact_made: true,
        hours: 1,
        minutes: 45,
        contact_topics: [contact_topics.first.question]
      )
    end

    it "has selected topics expanded but no details expanded" do
      topic_one_id = contact_topics.first.question.parameterize.underscore
      topic_two_id = contact_topics.last.question.parameterize.underscore

      expect(page).to have_text contact_topics.first.question
      expect(page).to_not have_text contact_topics.first.details

      within("##{topic_one_id}") do
        expect(page).to have_text("read more")
        expect(page).to have_selector("##{topic_one_id} textarea")
      end

      expect(page).to have_text contact_topics.last.question
      expect(page).to_not have_text contact_topics.last.details
      expect(page).to_not have_selector("##{topic_two_id}")
    end

    it "expands to show and hide the text field and details", js: true do
      click_on "read more"
      topic_id = contact_topics.first.question.parameterize.underscore

      expect(page).to have_text(contact_topics.first.question)
      expect(page).to have_text(contact_topics.first.details)
      expect(page).to have_selector("##{topic_id} textarea")

      find("##{topic_id}_button").click

      expect(page).to have_text(contact_topics.first.question)
      expect(page).to_not have_text(contact_topics.first.details)
      expect(page).to_not have_selector("##{topic_id} textarea")

      find("##{topic_id}_button").click

      expect(page).to have_text(contact_topics.first.question)
      expect(page).to have_text(contact_topics.first.details)
      expect(page).to have_selector("##{topic_id} textarea")
    end

    it "expands to show/hide details", js: true do
      topic_id = contact_topics.first.question.parameterize.underscore

      expect(page).to have_text(contact_topics.first.question)

      within("##{topic_id}") do
        expect(page).to_not have_text(contact_topics.first.details)
        expect(page).to have_selector("##{topic_id} textarea")

        click_on "read more"

        expect(page).to have_text(contact_topics.first.details)
        expect(page).to have_selector("##{topic_id} textarea")

        click_on "read less"

        expect(page).to_not have_text(contact_topics.first.details)
        expect(page).to have_selector("##{topic_id} textarea")
      end
    end
  end

  context "when the org has neither reimbursable expenses nor travel" do
    before do
      FeatureFlagService.disable!(FeatureFlagService::SHOW_ADDITIONAL_EXPENSES_FLAG)
      allow_any_instance_of(CasaOrg).to receive(:show_driving_reimbursement).and_return(false)
      sign_in volunteer
    end

    it "should create a case contact" do
      visit case_contacts_path

      click_on "New Case Contact"
      complete_details_page(case_numbers: [casa_case.case_number], medium: "In Person", contact_made: true, hours: 1, minutes: 45)
      complete_notes_page(click_continue: false)

      click_on "Submit"

      expect(page).to have_text "Case contact successfully created"
    end
  end
end
