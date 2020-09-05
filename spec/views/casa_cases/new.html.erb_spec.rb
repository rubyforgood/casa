require "rails_helper"

describe "casa_cases/new" do
  include Devise::TestHelpers

  context "while signed in as admin" do
    before do
      user = create(:casa_admin)
      sign_in(user)
      assign :casa_case, Supervisor.new
    end

    fit "has a button to Return to Dashboard" do
      render template: "casa_cases/new"
      expect(rendered).to have_selector("a", text: "Return to Dashboard")
    end
  end
end
