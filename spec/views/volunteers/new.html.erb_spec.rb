require "rails_helper"

describe "volunteers/new" do
  include Devise::TestHelpers

  context "while signed in as admin" do
    before do
      user = create(:casa_admin)
      sign_in(user)
      assign :volunteer, Volunteer.new
    end

    fit "has a button to Return to Dashboard" do
      render template: "volunteers/new"
      expect(rendered).to have_selector("a", text: "Return to Dashboard")
    end
  end
end
