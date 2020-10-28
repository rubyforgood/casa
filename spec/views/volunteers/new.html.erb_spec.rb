require "rails_helper"

RSpec.describe "volunteers/new" do
  subject { render template: "volunteers/new" }

  before do
    assign :volunteer, Volunteer.new
  end

  context "while signed in as admin" do
    before do
      sign_in_as_admin
    end

    it { is_expected.to have_selector("a", text: "Return to Dashboard") }
  end
end
