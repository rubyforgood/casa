require "rails_helper"

RSpec.describe "user inputs dangerous values", type: :system do
  it "is successful", js: false do
    admin = create(:casa_admin)
    volunteer = create(:volunteer)

    sign_in admin
    visit edit_volunteer_path(volunteer)

    UserInputHelpers::DANGEROUS_STRINGS.each do |dangerous_string|
      fill_in "Display name", with: dangerous_string

      click_on "Submit"
      expect(page).to have_content("Volunteer was successfully updated.")

      volunteer.reload

      expect(volunteer.display_name).to eq dangerous_string
    end
  end
end
