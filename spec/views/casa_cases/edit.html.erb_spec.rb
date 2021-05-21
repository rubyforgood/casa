require "rails_helper"

RSpec.describe "casa_cases/edit", :disable_bullet, type: :view do
  let(:organization) { create(:casa_org) }

  before do
    enable_pundit(view, user)
    assign :contact_types, []
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

  context "when assigning a new volunteer" do
    let(:user) { build_stubbed(:casa_admin, casa_org: organization) }

    it "does not have an option to select a volunteer that is already assigned to the casa case" do
      casa_case = create(:casa_case, casa_org: organization)
      assign :casa_case, casa_case
      assigned_volunteer = create(:volunteer)
      create(:case_assignment, volunteer: assigned_volunteer, casa_case: casa_case)
      unassigned_volunteer = create(:volunteer)

      render template: "casa_cases/edit"

      expect(rendered).to have_select("case_assignment_casa_case_id",
        options: [unassigned_volunteer.display_name])
    end
  end
end
