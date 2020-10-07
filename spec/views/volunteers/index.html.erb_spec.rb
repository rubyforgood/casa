require "rails_helper"

describe "volunteers" do
  subject { render template: "volunteers/index" }

  context "while signed in as other user diferent to admin" do
    before do
      sign_in_as_volunteer
    end

    it { is_expected.not_to have_selector("a", text: "New Volunteer") }
  end
end
