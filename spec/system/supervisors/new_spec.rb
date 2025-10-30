# frozen_string_literal: true

require "rails_helper"

RSpec.describe "supervisors/new", type: :system do
  context "when admin" do
    let(:admin) { create(:casa_admin) }
    let(:new_supervisor_name) { Faker::Name.name }
    let(:new_supervisor_email) { Faker::Internet.email }
    let(:new_supervisor_phone_number) { Faker::PhoneNumber.phone_number }

    before do
      # Stub the request to the URL shortener service (needed if phone is provided)
      stub_request(:post, "https://api.short.io/links")
        .to_return(
          status: 200,
          body: {shortURL: "https://short.url/example"}.to_json,
          headers: {"Content-Type" => "application/json"}
        )
    end

    it "allows admin to create a new supervisors" do
      sign_in admin
      visit new_supervisor_path

      fill_in "Email", with: new_supervisor_email
      fill_in "Display name", with: new_supervisor_name
      fill_in "Phone number", with: new_supervisor_phone_number

      click_on "Create Supervisor"

      expect(page).to have_text("New supervisor created successfully.")
      expect(User.count).to eq(2) # admin + new supervisor

      new_supervisor = User.find_by(email: new_supervisor_email)

      expect(page).to have_current_path(edit_supervisor_path(new_supervisor))

      expect(new_supervisor).to be_present
      expect(new_supervisor.display_name).to eq(new_supervisor_name)
      expect(new_supervisor.phone_number).to eq(new_supervisor_phone_number)
      expect(new_supervisor.supervisor?).to eq(true)
      expect(new_supervisor.active?).to eq(true)
    end

    it "sends invitation email to the new supervisor", :aggregate_failures do
      sign_in admin
      visit new_supervisor_path

      fill_in "Email", with: new_supervisor_email
      fill_in "Display name", with: new_supervisor_name
      fill_in "Phone number", with: new_supervisor_phone_number

      click_on "Create Supervisor"

      expect(page).to have_text("New supervisor created successfully.")

      last_email = ActionMailer::Base.deliveries.last
      expect(last_email.to).to eq [new_supervisor_email]
      expect(last_email.subject).to have_text "CASA Console invitation instructions"
      expect(last_email.html_part.body.encoded).to have_text "your new Supervisor account."
    end
  end

  context "volunteer user" do
    let(:volunteer) { create(:volunteer) }

    before { sign_in volunteer }

    it "redirects the user with an error message" do
      visit new_supervisor_path

      expect(page).to have_selector(".alert", text: "Sorry, you are not authorized to perform this action.")
    end
  end
end
