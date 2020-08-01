require "rails_helper"

RSpec.describe "user inputs dangerous values", type: :feature do
  it "is successful" do
    admin = create(:casa_admin)
    volunteer = create(:volunteer)
    
    UserInputHelpers::DANGEROUS_STRINGS.each do |dangerous_string|

      sign_in admin
      visit edit_volunteer_path(volunteer)

      fill_in "Display name", with: dangerous_string

      click_on "Submit"
      expect(page).to have_content("Volunteer was successfully updated.")

      volunteer.reload

      expect(volunteer.display_name).to eq dangerous_string
    end
  end
end
