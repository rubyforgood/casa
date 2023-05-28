require "rails_helper"

RSpec.describe "imports/index", type: :system do
  let(:volunteer) { create(:volunteer) }
  let(:admin) { create(:casa_admin) }

  context "as a volunteer" do
    before { sign_in volunteer }

    it "redirects the user with an error message" do
      visit imports_path

      expect(page).to have_selector(".alert", text: "Sorry, you are not authorized to perform this action.")
    end
  end

  context "import volunteer csv with phone numbers", js: true do
    let(:import_file_path) { Rails.root.join("spec", "fixtures", "volunteers.csv") }

    it "shows sms opt in modal" do
      sign_in admin
      visit imports_path(:volunteer)

      expect(page).to have_content("Import Volunteers")
      expect(page).to have_button("volunteer-import-button", disabled: true)

      attach_file "volunteer-file", import_file_path
      click_button "volunteer-import-button"

      expect(page).to have_text("SMS Opt In")
      expect(page).to have_button("sms-opt-in-continue-button", disabled: true)

      check "sms-opt-in-checkbox"
      click_button "sms-opt-in-continue-button"

      expect(page).to have_text("You successfully imported")
    end
  end

  context "import volunteer csv without phone numbers", js: true do
    let(:import_file_path) { Rails.root.join("spec", "fixtures", "volunteers_without_phone_numbers.csv") }

    it "shows successful import" do
      sign_in admin
      visit imports_path(:volunteer)

      expect(page).to have_content("Import Volunteers")

      attach_file "volunteer-file", import_file_path
      click_button "volunteer-import-button"

      expect(page).to have_text("You successfully imported")
    end
  end

  context "import supervisors csv with phone numbers", js: true do
    let(:import_file_path) { Rails.root.join("spec", "fixtures", "supervisors.csv") }

    it "shows sms opt in modal" do
      sign_in admin
      visit imports_path
      click_on "supervisor-tab"

      expect(page).to have_content("Import Supervisors")
      expect(page).to have_button("supervisor-import-button", disabled: true)

      attach_file "supervisor-file", import_file_path
      click_button "supervisor-import-button"

      expect(page).to have_text("SMS Opt In")
      expect(page).to have_button("sms-opt-in-continue-button", disabled: true)

      check "sms-opt-in-checkbox"
      click_button "sms-opt-in-continue-button"

      expect(page).to have_text("You successfully imported")
    end
  end

  context "import supervisors csv without phone numbers", js: true do
    it "shows successful import" do
      import_file_path = Rails.root.join("spec", "fixtures", "supervisors_without_phone_numbers.csv")

      sign_in admin
      visit imports_path

      click_on "Import Supervisors"

      expect(page).to have_content("Import Supervisors")

      attach_file "supervisor-file", import_file_path
      click_button "supervisor-import-button"

      expect(page).to have_text("You successfully imported")
    end
  end
end
