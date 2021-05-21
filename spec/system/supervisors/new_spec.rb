# frozen_string_literal: true

require "rails_helper"

RSpec.describe "supervisors/new", :disable_bullet, type: :system do
  context "when admin" do
    let(:admin) { create(:casa_admin) }

    it "allows admin to create a new supervisors" do
      sign_in admin
      visit new_supervisor_path

      fill_in "Email", with: "new_supervisor_email@example.com"
      fill_in "Display Name", with: "New Supervisor Display Name"

      expect {
        click_on "Create Supervisor"
      }.to change(User, :count).by(1)
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
