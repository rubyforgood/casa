require "rails_helper"

RSpec.describe "volunteers", type: :view do
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

  describe "supervisor's dropdown" do
    let!(:supervisor_volunteer) { create(:supervisor_volunteer, volunteer: volunteer, supervisor: supervisor) }

    context "when the supervisor is active" do
      let(:supervisor) { build(:supervisor) }

      it "shows up in the supervisor dropdown" do
        expect(subject).to include(CGI.escapeHTML(supervisor.display_name))
      end
    end

    context "when the supervisor is not active" do
      let(:supervisor) { build(:supervisor, active: false) }

      it "doesn't show up in the dropdown" do
        expect(subject).not_to include(supervisor.display_name)
      end
    end
  end
end
