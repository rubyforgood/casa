require "rails_helper"

RSpec.describe "casa_cases/edit" do
  let(:organization) { create(:casa_org) }

  before do
    enable_pundit(view, user)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:current_organization).and_return(user.casa_org)
  end

  context "when accessed by a volunteer" do
    let(:user) { build_stubbed(:volunteer, casa_org: organization) }

    it "does not include volunteer assignment" do
      assign :casa_case, create(:casa_case, casa_org: organization)

      render template: "casa_cases/edit"

      expect(rendered).not_to include("Assign a New Volunteer")
      expect(rendered).not_to include(CGI.escapeHTML("Youth's Birth Month & Year"))
    end
  end

  context "when accessed by an admin" do
    let(:user) { build_stubbed(:casa_admin, casa_org: organization) }

    it "includes volunteer assignment" do
      assign :casa_case, create(:casa_case, casa_org: organization)

      render template: "casa_cases/edit"

      expect(rendered).to include("Assign a New Volunteer")
      expect(rendered).to include(CGI.escapeHTML("Youth's Birth Month & Year"))
    end
  end
end
