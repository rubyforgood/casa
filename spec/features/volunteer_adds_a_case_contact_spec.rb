require "rails_helper"

RSpec.feature "volunteer adds a case contact", type: :feature do
  scenario "is successful" do
    volunteer = create(:user, :volunteer, :with_casa_cases)

    sign_in volunteer

    visit new_case_contact_path
    within "select#contact_type" do
      select "School"
    end

    within "select#duration_minutes" do
      select "60 minutes"
    end

    # find(:css, "#case_contact_occurred_at".)
    fill_in "case_contact_occurred_at", with: "04/04/2020"

    click_on "Submit"

    expect(CaseContact.first.contact_type).to eq "school"
  end
end
