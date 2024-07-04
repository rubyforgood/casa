require "rails_helper"

RSpec.describe "casa_cases/new", type: :view do
  let(:casa_org) { create(:casa_org) }
  let(:user) { create(:casa_admin, casa_org: casa_org) }
  let(:contact_type_group) { create(:contact_type_group, casa_org: casa_org) }
  let(:contact_type) { create(:contact_type, contact_type_group: contact_type_group) }

  context "while signed in as admin" do
    it "has youth birth month and year" do
      enable_pundit(view, user)
      allow(view).to receive(:current_user).and_return(user)
      allow(view).to receive(:current_organization).and_return(casa_org)

      assign :casa_case, build(:casa_case, casa_org: casa_org)
      assign :contact_types, casa_org.contact_types

      render template: "casa_cases/new"

      expect(rendered).to include("Youth's Birth Month & Year")
    end
  end

  context "when trying to assign a volunteer to a case" do
    it "should be able to assign volunteers" do
      enable_pundit(view, user)
      allow(view).to receive(:current_user).and_return(user)
      allow(view).to receive(:current_organization).and_return(user.casa_org)

      assign :casa_case, build(:casa_case, casa_org: user.casa_org)
      assign :contact_types, casa_org.contact_types

      render template: "casa_cases/new"

      expect(rendered).to have_content("Assign a Volunteer")
      expect(rendered).to have_css("#casa_case_assigned_volunteer_id")
    end
  end
end
