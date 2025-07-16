require "rails_helper"

RSpec.describe "court_dates/edit", type: :system do
  let(:organization) { create(:casa_org) }

  let(:now) { Date.new(2021, 1, 1) }
  let(:displayed_date_format) { "%B %e, %Y" }
  let(:casa_case_number) { "CASA-CASE-NUMBER" }
  let!(:casa_case) { create(:casa_case, casa_org: organization, case_number: casa_case_number) }
  let(:court_date_as_date_object) { now + 1.week }
  let(:court_report_due_date_as_object) { now + 2.weeks }
  let!(:court_date) { create(:court_date, :with_court_details, casa_case: casa_case, court_report_due_date: court_report_due_date_as_object, date: court_date_as_date_object) }

  before do
    travel_to now
  end

  shared_examples "a user able to view court date" do |user_type|
    let(:user) { create(user_type, casa_org: organization) }

    before(:all) do
      sign_in user
      visit casa_case_court_date_path(casa_case, court_date)
    end

    it "can visit the court order page" do
      expect(page).not_to have_text "Sorry, you are not authorized to perform this action."
    end

    it "can see the court date" do
      expect(page).to have_text court_date_as_date_object.strftime(displayed_date_format)
    end

    it "can see the associated case number" do
      expect(page).to have_text casa_case_number
    end

    it "can see the associated court report due date" do
      expect(page).to have_text court_report_due_date.strftime(displayed_date_format)
    end

    it "can see the associated judge" do
    end

    it "can see the associated hearing type" do
    end

    it "can see associated court orders" do
    end
  end

  shared_examples "a user unable to view court date" do |user_type|
    let(:user) { create(user_type, casa_org: organization) }

    it "is not allowed to visit the court order page" do
      sign_in user
      visit casa_case_court_date_path(casa_case, court_date)

      expect(page).to have_text "Sorry, you are not authorized to perform this action."
    end
  end

  context "as a user from an organization not containing the court date" do
    let(:organization) { create(:casa_org) }

    it_should_behave_like "a user unable to view court date", :casa_admin
  end

  context "as a user under the same org as the court date" do
    context "as a volunteer not assigned to the case associated with the court date" do
      it_should_behave_like "a user unable to view court date", :volunteer
    end

    context "as a volunteer assigned to the case associated with the court date" do
      it_should_behave_like "a user able to view court date"
    end
  end
end
