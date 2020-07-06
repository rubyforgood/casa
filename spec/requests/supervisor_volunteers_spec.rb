require "rails_helper"

RSpec.describe "DELETE /supervisor_volunteers/:id", type: :request do
  it "destroys the assignment of a volunteer to a supervisor" do
    admin = create(:user, :casa_admin)
    supervisor = create(:user, :supervisor)
    volunteer = create(:user, :volunteer)
    assignment = create(:supervisor_volunteer, supervisor: supervisor, volunteer: volunteer)

    sign_in admin

    expect do
      delete supervisor_volunteer_path(assignment, supervisor_id: supervisor.id)
    end.to change(supervisor.volunteers, :count).by(-1)

    expect(response).to redirect_to edit_supervisor_path(supervisor)
  end
end
