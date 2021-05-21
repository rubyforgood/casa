require "rails_helper"

RSpec.describe "sessions/destroy", :disable_bullet, type: :system do
  context "when a user is timed out" do
    let(:user) { create(:casa_admin) }

    before { sign_in user }

    it "ends the current session and redirects to sign in page after timeout" do
      allow(user).to receive(:timedout?).and_return(true)
      visit "/case_contacts/new"
      expect(page.current_path).to eq "/users/sign_in"
      expect(page).to have_text "Your session expired. Please sign in again to continue."
    end
  end
end
