# frozen_string_literal: true

require "rails_helper"

RSpec.describe "supervisors/new", type: :system do
  context "when admin" do
    let(:admin) { create(:casa_admin) }

    it "allows admin to create a new supervisors" do
      sign_in admin
      visit new_supervisor_path

      fill_in "Email", with: "new_supervisor_email@example.com"
      fill_in "Display name", with: "New Supervisor Display Name"

      expect {
        click_on "Create Supervisor"
      }.to change(User, :count).by(1)
    end

    it "sends invitation email to the new supervisor" do
      sign_in admin
      visit new_supervisor_path

      fill_in "Email", with: "new_supervisor_email2@example.com"
      fill_in "Display name", with: "New Supervisor Display Name 2"

      click_on "Create Supervisor"

      last_email = ActionMailer::Base.deliveries.last
      expect(last_email.to).to eq ["new_supervisor_email2@example.com"]
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
