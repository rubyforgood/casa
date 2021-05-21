require "rails_helper"

RSpec.describe "volunteers", :disable_bullet, type: :view do
  subject { render template: "volunteers/index" }

  let(:user) { build_stubbed :volunteer }
  let(:volunteer) { create :volunteer }

  before do
    enable_pundit(view, user)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_organization).and_return user.casa_org
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
end
