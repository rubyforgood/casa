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
    assign :available_volunteers, []

    render template: "supervisors/edit"

    expect(rendered).to_not include(unassign_supervisor_volunteer_path(volunteer))
    expect(rendered).to include("Unassigned")
  end
end
