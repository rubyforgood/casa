require "rails_helper"

RSpec.describe "supervisors/edit", type: :view do
  before do
    admin = build_stubbed :casa_admin
    enable_pundit(view, admin)
    allow(view).to receive(:current_user).and_return(admin)
  end

  it "displays the 'Unassign' button next to volunteer being currently supervised by the supervisor" do
    supervisor = create :supervisor
    volunteer = create :volunteer, supervisor: supervisor

    assign :supervisor, supervisor
    assign :all_volunteers_ever_assigned, [volunteer]
    assign :available_volunteers, []

    render template: "supervisors/edit"

    expect(rendered).to include(unassign_supervisor_volunteer_path(volunteer))
    expect(rendered).to_not include("Unassigned")
  end

  it "does not display the 'Unassign' button next to volunteer no longer supervised by the supervisor" do
    casa_org = create :casa_org
    supervisor = create :supervisor, casa_org: casa_org
    volunteer = create :volunteer, casa_org: casa_org
    create :supervisor_volunteer, :inactive, supervisor: supervisor, volunteer: volunteer

    assign :supervisor, supervisor
    assign :all_volunteers_ever_assigned, [volunteer]
    assign :available_volunteers, []

    render template: "supervisors/edit"

    expect(rendered).to_not include(unassign_supervisor_volunteer_path(volunteer))
    expect(rendered).to include("Unassigned")
  end

  describe "does not allow" do
    let(:volunteer) { create :volunteer }
    let(:supervisor) { build_stubbed :supervisor }
    let(:admin) { build_stubbed :casa_admin }

    it "a supervisor to edit a supervisor last sign in" do
      enable_pundit(view, supervisor)
      allow(view).to receive(:current_user).and_return(supervisor)

      assign :supervisor, supervisor
      assign :all_volunteers_ever_assigned, [volunteer]
      assign :available_volunteers, []

      render template: "supervisors/edit"

      expect(rendered).to have_field("supervisor_last_sign_in_at", disabled: true)
    end

    it "an admin to edit a supervisor last sign in" do
      enable_pundit(view, supervisor)
      allow(view).to receive(:current_user).and_return(admin)

      assign :supervisor, supervisor
      assign :all_volunteers_ever_assigned, [volunteer]
      assign :available_volunteers, []

      render template: "supervisors/edit"

      expect(rendered).to have_field("supervisor_last_sign_in_at", disabled: true)
    end
  end
end
