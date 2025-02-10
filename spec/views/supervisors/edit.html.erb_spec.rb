require "rails_helper"

RSpec.describe "supervisors/edit", type: :view do
  before do
    admin = build_stubbed :casa_admin
    enable_pundit(view, admin)
    allow(view).to receive(:current_user).and_return(admin)
    allow(view).to receive(:current_organization).and_return(admin.casa_org)
  end

  it "displays the 'Unassign' button next to volunteer being currently supervised by the supervisor" do
    supervisor = create :supervisor
    volunteer = create :volunteer, supervisor: supervisor

    assign :supervisor, supervisor
    assign :all_volunteers_ever_assigned, [volunteer]
    assign :available_volunteers, []

    render template: "supervisors/edit"

    expect(rendered).to include(unassign_supervisor_volunteer_path(volunteer))
    expect(rendered).not_to include("Unassigned")
  end

  it "does not display the 'Unassign' button next to volunteer no longer supervised by the supervisor" do
    casa_org = create :casa_org
    supervisor = create :supervisor, casa_org: casa_org
    volunteer = create :volunteer, casa_org: casa_org
    create :supervisor_volunteer, :inactive, supervisor: supervisor, volunteer: volunteer

    assign :supervisor, supervisor
    assign :supervisor_has_unassigned_volunteers, true
    assign :all_volunteers_ever_assigned, [volunteer]
    assign :available_volunteers, []

    render template: "supervisors/edit"

    expect(rendered).not_to include(unassign_supervisor_volunteer_path(volunteer))
    expect(rendered).to include("Unassigned")
  end

  describe "invite and login info" do
    let(:volunteer) { create :volunteer }
    let(:supervisor) { build_stubbed :supervisor }
    let(:admin) { build_stubbed :casa_admin }

    it "shows for a supervisor editig a supervisor" do
      enable_pundit(view, supervisor)
      allow(view).to receive(:current_user).and_return(supervisor)
      allow(view).to receive(:current_organization).and_return(supervisor.casa_org)
      assign :supervisor, supervisor
      assign :all_volunteers_ever_assigned, [volunteer]
      assign :available_volunteers, []

      render template: "supervisors/edit"

      expect(rendered).to have_text("Added to system ")
      expect(rendered).to have_text("Invitation email sent \n  never")
      expect(rendered).to have_text("Last logged in")
      expect(rendered).to have_text("Invitation accepted \n  never")
      expect(rendered).to have_text("Password reset last sent \n  never")
    end

    it "shows profile info form fields as editable for a supervisor editing their own profile" do
      enable_pundit(view, supervisor)
      allow(view).to receive(:current_organization).and_return(supervisor.casa_org)
      assign :supervisor, supervisor
      assign :all_volunteers_ever_assigned, [volunteer]
      assign :available_volunteers, []

      render template: "supervisors/edit"

      expect(rendered).to have_field("supervisor_email")
      expect(rendered).to have_field("supervisor_display_name")
      expect(rendered).to have_field("supervisor_phone_number")
    end

    it "shows profile info form fields as disabled for a supervisor editing another supervisor" do
      enable_pundit(view, supervisor)
      allow(view).to receive(:current_organization).and_return(supervisor.casa_org)
      assign :supervisor, build_stubbed(:supervisor, casa_org: build_stubbed(:casa_org))
      assign :all_volunteers_ever_assigned, [volunteer]
      assign :available_volunteers, []

      render template: "supervisors/edit"

      expect(rendered).not_to have_field("supervisor_email")
      expect(rendered).not_to have_field("supervisor_display_name")
      expect(rendered).not_to have_field("supervisor_phone_number")
    end

    it "shows for an admin editing a supervisor" do
      enable_pundit(view, supervisor)
      allow(view).to receive(:current_user).and_return(admin)

      assign :supervisor, supervisor
      assign :all_volunteers_ever_assigned, [volunteer]
      assign :available_volunteers, []

      render template: "supervisors/edit"

      expect(rendered).to have_text("Added to system ")
      expect(rendered).to have_text("Invitation email sent \n  never")
      expect(rendered).to have_text("Last logged in")
      expect(rendered).to have_text("Invitation accepted \n  never")
      expect(rendered).to have_text("Password reset last sent \n  never")
    end
  end

  describe "'Change to Admin' button" do
    let(:supervisor) { build_stubbed :supervisor }

    before do
      assign :supervisor, supervisor
      assign :available_volunteers, []
    end

    it "shows for an admin editing a supervisor" do
      render template: "supervisors/edit"

      expect(rendered).to have_text("Change to Admin")
      expect(rendered).to include(change_to_admin_supervisor_path(supervisor))
    end

    it "does not show for a supervisor editing a supervisor" do
      enable_pundit(view, supervisor)
      allow(view).to receive(:current_user).and_return(supervisor)
      allow(view).to receive(:current_organization).and_return(supervisor.casa_org)
      render template: "supervisors/edit"

      expect(rendered).not_to have_text("Change to Admin")
      expect(rendered).not_to include(change_to_admin_supervisor_path(supervisor))
    end
  end
end
