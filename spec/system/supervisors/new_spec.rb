# frozen_string_literal: true

require "rails_helper"

RSpec.describe "supervisors/new", type: :system do
  context "when logged in as an admin" do
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

      sign_in admin
      visit new_supervisor_path
    end

    context "with valid form submission" do
      let(:new_supervisor) { User.find_by(email: new_supervisor_email) }

      before do
        fill_in "Email", with: new_supervisor_email
        fill_in "Display name", with: new_supervisor_name
        fill_in "Phone number", with: new_supervisor_phone_number

        click_on "Create Supervisor"
      end

      it "shows a success message" do
        expect(page).to have_text("New supervisor created successfully.")
      end

      it "redirects to the edit supervisor page" do
        expect(page).to have_current_path(edit_supervisor_path(new_supervisor))
      end

      it "persists the new supervisor with correct attributes", :aggregate_failures do
        expect(new_supervisor).to be_present
        expect(new_supervisor.display_name).to eq(new_supervisor_name)
        expect(new_supervisor.phone_number).to eq(new_supervisor_phone_number)
        expect(new_supervisor.supervisor?).to be(true)
        expect(new_supervisor.active?).to be(true)
      end

      it "sends an invitation email to the new supervisor", :aggregate_failures do
        last_email = ActionMailer::Base.deliveries.last
        expect(last_email.to).to eq [new_supervisor_email]
        expect(last_email.subject).to have_text "CASA Console invitation instructions"
        expect(last_email.html_part.body.encoded).to have_text "your new Supervisor account."
      end
    end

    context "with invalid form submission" do
      before do
        # Don't fill in any fields
        click_on "Create Supervisor"
      end

      it "does not create a new user" do
        expect(User.count).to eq(1) # Only the admin user exists
      end

      it "shows validation error messages" do
        expect(page).to have_text "errors prohibited this Supervisor from being saved:"
      end

      it "stays on the new supervisor page" do
        expect(page).to have_current_path(supervisors_path)
      end
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
