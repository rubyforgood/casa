require "rails_helper"

RSpec.describe "volunteers" do
  subject { render template: "volunteers/index" }

  let(:casa_org) { create :casa_org }
  let(:user) { build_stubbed :volunteer, casa_org: }
  let(:volunteer) { create :volunteer, casa_org: }

  before do
    enable_pundit(view, user)
    allow(view).to receive_messages(
      current_user: user,
      current_organization: user.casa_org
    )
    assign :volunteers, [volunteer]
    sign_in user
  end

  context "when NOT signed in as an admin" do
    it { is_expected.to have_no_css("a", text: "New Volunteer") }
  end

  context "when signed in as an admin" do
    let(:user) { build_stubbed :casa_admin, casa_org: }

    it { is_expected.to have_css("a", text: "New Volunteer") }
  end

  describe "supervisor's dropdown" do
    let!(:supervisor_volunteer) { create(:supervisor_volunteer, volunteer: volunteer, supervisor: supervisor) }

    context "when the supervisor is active" do
      let(:supervisor) { build(:supervisor, casa_org:) }

      it "shows up in the supervisor dropdown" do
        expect(subject).to include(CGI.escapeHTML(supervisor.display_name))
      end
    end

    context "when the supervisor is not active" do
      let(:supervisor) { build(:supervisor, active: false, casa_org:) }

      it "doesn't show up in the dropdown" do
        expect(subject).not_to include(supervisor.display_name)
      end
    end
  end
end
