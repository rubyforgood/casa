require "rails_helper"

describe "casa_cases/edit" do
  let(:organization) { create(:casa_org) }

  context "when accessed by a volunteer" do
    it "does not include volunteer assignment" do
      assign :casa_case, create(:casa_case, casa_org: organization)

      user = build_stubbed(:volunteer, casa_org: organization)
      allow(view).to receive(:current_user).and_return(user)

      render template: "casa_cases/edit"

      expect(rendered).not_to include("Assign a New Volunteer")
    end
  end

  context "when accessed by an admin" do
    it "includes volunteer assignment" do
      assign :casa_case, create(:casa_case, casa_org: organization)

      user = build_stubbed(:casa_admin, casa_org: organization)
      allow(view).to receive(:current_user).and_return(user)

      render template: "casa_cases/edit"

      expect(rendered).to include("Assign a New Volunteer")
    end
  end
end
