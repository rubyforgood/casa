require "rails_helper"

describe "volunteers" do
  subject { render template: "volunteers/index" }

  context "while signed in as other user diferent to admin" do
    let(:user) { build_stubbed :volunteer }

    before do
      enable_pundit(view, user)
      allow(view).to receive(:current_user).and_return(user)
      assign :volunteers, []
      sign_in user
    end

    it do
      is_expected.not_to have_selector("a", text: "New Volunteer")
    end
  end
end
