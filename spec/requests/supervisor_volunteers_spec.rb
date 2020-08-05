require "rails_helper"

RSpec.describe "DELETE /supervisor_volunteers/:id", type: :request do
  context "when the logged in user is an admin" do
    it "destroys the assignment of a volunteer to a supervisor" do
      admin = create(:casa_admin)
      supervisor = create(:supervisor)
      volunteer = create(:volunteer)
      assignment = create(:supervisor_volunteer, supervisor: supervisor, volunteer: volunteer)

      sign_in admin

      expect {
        delete supervisor_volunteer_path(assignment)
      }.to change(supervisor.volunteers, :count).by(-1)

      expect(response).to redirect_to edit_supervisor_path(supervisor)
    end
  end

  context "when the logged in user is a supervisor" do
    it "destroys the assignment of a volunteer to a supervisor" do
      supervisor = create(:supervisor)
      volunteer = create(:volunteer)
      assignment = create(:supervisor_volunteer, supervisor: supervisor, volunteer: volunteer)

      sign_in supervisor

      expect {
        delete supervisor_volunteer_path(assignment)
      }.to change(supervisor.volunteers, :count).by(-1)

      expect(response).to redirect_to edit_supervisor_path(supervisor)
    end
  end

  context "when the logged in user is not an admin or supervisor" do
    it "does not destroy the assignment" do
      supervisor = create(:supervisor)
      volunteer = create(:volunteer)
      assignment = create(:supervisor_volunteer, supervisor: supervisor, volunteer: volunteer)

      sign_in volunteer

      expect {
        delete supervisor_volunteer_path(assignment)
      }.to change(supervisor.volunteers, :count).by(0)
    end
  end
end
