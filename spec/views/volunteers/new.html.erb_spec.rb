require "rails_helper"

RSpec.describe "volunteers/new", type: :view do
  subject { render template: "volunteers/new" }

  before do
    assign :volunteer, Volunteer.new
  end

  context "while signed in as admin" do
    before do
      sign_in_as_admin
    end
  end
end
