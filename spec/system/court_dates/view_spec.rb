require "rails_helper"

RSpec.describe "court_dates/edit", type: :system do
  let(:organization) { create(:casa_org) }

  let(:now) { Date.new(2021, 1, 1) }
  let(:displayed_date_format) { "%B %-d, %Y" }
  let(:casa_case_number) { "CASA-CASE-NUMBER" }
  let!(:casa_case) { create(:casa_case, casa_org: organization, case_number: casa_case_number) }
  let(:court_date_as_date_object) { now + 1.week }
  let(:court_report_due_date) { now + 2.weeks }
  let!(:court_date) { create(:court_date, :with_court_details, casa_case: casa_case, court_report_due_date: court_report_due_date, date: court_date_as_date_object) }

  before do
    travel_to now
  end

  shared_examples "a user able to view court date" do |user_type|
    let(:user) { create(user_type, casa_org: organization) }

    it "can visit the court order page" do
      if user_type === :volunteer
        user.casa_cases << casa_case
      end

      sign_in user
      visit casa_case_court_date_path(casa_case, court_date)

      expect(page).not_to have_text "Sorry, you are not authorized to perform this action."
    end

    it "displays all information associated with the court date correctly" do
      if user_type === :volunteer
        user.casa_cases << casa_case
      end

      sign_in user
      visit casa_case_court_date_path(casa_case, court_date)

      expect(page).to have_text court_date_as_date_object.strftime(displayed_date_format)
      expect(page).to have_text court_report_due_date.strftime(displayed_date_format)
      expect(page).to have_text casa_case_number
      # Test judge none and set
      # Test hearing type none and set
      # Test court orders none and set
    end
  end

  context "as a user from an organization not containing the court date" do
    let(:other_organization) { create(:casa_org) }

    xit "does not allow the user to view the court date" do
      # TODO the app can't gracefully handle the URL
      sign_in create(:casa_admin, casa_org: other_organization)
      visit casa_case_court_date_path(casa_case, court_date)

      expect(page).to have_text "Sorry, you are not authorized to perform this action."
    end
  end

  context "as a user under the same org as the court date" do
    context "as a volunteer not assigned to the case associated with the court date" do
      let(:volunteer_not_assigned_to_case) { create(:volunteer, casa_org: organization) }

      it "does not allow the user to view the court date" do
        sign_in volunteer_not_assigned_to_case
        visit casa_case_court_date_path(casa_case, court_date)

        expect(page).to have_text "Sorry, you are not authorized to perform this action."
      end
    end

    context "as a volunteer assigned to the case associated with the court date" do
      it_should_behave_like "a user able to view court date", :volunteer
    end

    context "as a supervisor belonging to the same org as the case associated with the court date" do
      it_should_behave_like "a user able to view court date", :supervisor
    end

    context "as an admin belonging to the same org as the case associated with the court date" do
      it_should_behave_like "a user able to view court date", :casa_admin
    end
  end
end
