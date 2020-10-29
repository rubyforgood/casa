require "rails_helper"

describe "volunteers" do
  subject { render template: "volunteers/index" }
  let(:user) { build_stubbed :volunteer }
  let(:volunteer) { create :volunteer }

  before do
    enable_pundit(view, user)
    allow(view).to receive(:current_user).and_return(user)
    assign :volunteers, [volunteer]
    sign_in user
  end

  context "when NOT signed in as an admin" do
    it { is_expected.not_to have_selector("a", text: "New Volunteer") }
  end

  context "when signed in as an admin" do
    let(:user) { build_stubbed :casa_admin }

    it { is_expected.to have_selector("a", text: "New Volunteer") }
  end

  context "links" do
    it { is_expected.to have_link(volunteer.decorate.name) }
  end
end
