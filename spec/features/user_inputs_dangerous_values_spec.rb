require "rails_helper"

RSpec.describe "user inputs dangerous values", type: :feature do
  it "is successful" do
    admin = create(:user, :casa_admin)
    volunteer = create(:user, :volunteer)
    dangerous_string = UserInputHelpers::DANGEROUS_STRINGS.sample

    sign_in admin
    visit edit_volunteer_path(volunteer)

    fill_in "Display name", with: dangerous_string

    click_on "Submit"
    expect(page).to have_content("Volunteer was successfully updated.")

    volunteer.reload

    expect(volunteer.display_name).to eq dangerous_string
  end
end
