require "rails_helper"

RSpec.describe "casa_admins/edit", type: :view do
  let(:admin) { build_stubbed :casa_admin }

  it "shows invite and login info" do
    enable_pundit(view, admin)
    allow(view).to receive(:current_user).and_return(admin)
    allow(view).to receive(:current_organization).and_return(admin.casa_org)
    assign :casa_admin, admin

    render template: "casa_admins/edit"

    expect(rendered).to have_text("Added to system ")
    expect(rendered).to have_text("Invitation email sent \n    never")
    expect(rendered).to have_text("Last logged in")
    expect(rendered).to have_text("Invitation accepted \n    never")
    expect(rendered).to have_text("Password reset last sent \n    never")
  end

  describe "'Change to Supervisor' button" do
    let(:supervisor) { build_stubbed :supervisor }

    before do
      assign :casa_admin, admin
      assign :available_volunteers, []
    end

    it "shows for an admin editing an admin" do
      enable_pundit(view, admin)
      allow(view).to receive(:current_user).and_return(admin)
      allow(view).to receive(:current_organization).and_return(admin.casa_org)
      render template: "casa_admins/edit"

      expect(rendered).to have_text("Change to Supervisor")
      expect(rendered).to include(change_to_supervisor_casa_admin_path(admin))
    end

    it "does not show for a supervisor editing an admin" do
      enable_pundit(view, admin)
      allow(view).to receive(:current_user).and_return(supervisor)
      allow(view).to receive(:current_organization).and_return(supervisor.casa_org)
      render template: "casa_admins/edit"

      expect(rendered).not_to have_text("Change to Supervisor")
      expect(rendered).not_to include(change_to_supervisor_casa_admin_path(admin))
    end
  end
end
