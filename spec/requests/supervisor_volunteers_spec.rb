require "rails_helper"

RSpec.describe "/supervisor_volunteers", type: :request do
  context "PATCH /unassign" do
    let!(:admin) { create(:casa_admin) }
    let!(:supervisor) { create(:supervisor) }
    let!(:volunteer) { create(:volunteer) }
    let!(:association) do
      create(:supervisor_volunteer, supervisor: supervisor, volunteer: volunteer)
    end

    context "when the logged in user is an admin" do
      it "sets the is_active flag for assignment of a volunteer to a supervisor to false" do
        sign_in admin

        expect {
          patch unassign_supervisor_volunteer_path(volunteer)
        }.not_to change(supervisor.volunteers, :count)

        association.reload
        expect(association.is_active).to be(false)
        expect(response).to redirect_to edit_supervisor_path(supervisor)
      end
    end

    context "when the logged in user is a supervisor" do
      it "sets the is_active flag for assignment of a volunteer to a supervisor to false" do
        sign_in supervisor

        expect {
          patch unassign_supervisor_volunteer_path(volunteer)
        }.not_to change(supervisor.volunteers, :count)

        association.reload
        expect(association.is_active).to be(false)
        expect(response).to redirect_to edit_supervisor_path(supervisor)
      end
    end

    context "when the logged in user is not an admin or supervisor" do
      it "does not set the is_active flag on the association to false" do
        supervisor = create(:supervisor)
        volunteer = create(:volunteer)
        assignment = create(:supervisor_volunteer, supervisor: supervisor, volunteer: volunteer)

        sign_in volunteer

        expect {
          patch unassign_supervisor_volunteer_path(volunteer)
        }.not_to change(supervisor.volunteers, :count)

        assignment.reload

        expect(assignment.is_active).to be(true)
      end
    end
  end
end
