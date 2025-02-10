require "rails_helper"

RSpec.describe "sessions/destroy", type: :system do
  context "when a user is timed out" do
    let(:user) { build(:casa_admin) }

    before { sign_in user }

    it "ends the current session and redirects to sign in page after timeout" do
      allow(user).to receive(:timedout?).and_return(true)
      visit "/case_contacts/new"
      expect(page).to have_current_path "/users/sign_in", ignore_query: true
      expect(page).to have_text "Your session expired. Please sign in again to continue."
    end
  end
end
