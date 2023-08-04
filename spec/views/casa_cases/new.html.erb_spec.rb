require "rails_helper"

RSpec.describe "casa_cases/new", type: :view do
  context "while signed in as admin" do
    it "has youth birth month and year" do
      user = build_stubbed(:casa_admin)
      enable_pundit(view, user)
      allow(view).to receive(:current_user).and_return(user)
      allow(view).to receive(:current_organization).and_return(user.casa_org)

      assign :casa_case, build(:casa_case, casa_org: user.casa_org)
      assign :contact_types, []

      render template: "casa_cases/new"

      expect(rendered).to include CGI.escapeHTML("Youth's Birth Month & Year")
    end
  end

  context "when trying to assign a volunteer to a case" do
    it "should not be able to assign volunteers" do
      user = build_stubbed(:casa_admin)
      enable_pundit(view, user)
      allow(view).to receive(:current_user).and_return(user)
      allow(view).to receive(:current_organization).and_return(user.casa_org)

      assign :casa_case, build(:casa_case, casa_org: user.casa_org)
      assign :contact_types, []

      render template: "casa_cases/new"

      expect(rendered).not_to have_content("Manage Volunteers")
      expect(rendered).not_to have_css("#volunteer-assignment")
    end
  end
end
