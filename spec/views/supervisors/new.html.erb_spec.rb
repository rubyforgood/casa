require "rails_helper"

describe "supervisors/new" do
  include Devise::TestHelpers

  context "while signed in as admin" do
    before do
      user = build_stubbed(:casa_admin)
      sign_in(user)
      assign :supervisor, Supervisor.new
    end

    fit "has a button to Return to Dashboard" do
      render template: "supervisors/new"
      expect(rendered).to have_selector("a", text: "Return to Dashboard")
    end
  end
end
