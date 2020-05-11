require "rails_helper"

RSpec.describe "/case_assignments", type: :request do
  describe "POST /create" do
    it "creates a new case assignment" do
      admin = create(:user, :casa_admin)
      volunteer = create(:user, :volunteer)
      casa_case = create(:casa_case)

      sign_in admin

      expect {
        post volunteer_case_assignments_url(volunteer),
          params: {case_assignment: {casa_case_id: casa_case.id}}
      }.to change(volunteer.casa_cases, :count).by(1)

      expect(response).to redirect_to edit_volunteer_path(volunteer)
    end
  end

  describe "DELETE /destroy" do
    it "destroys the case assignment" do
      admin = create(:user, :casa_admin)
      volunteer = create(:user, :volunteer)
      casa_case = create(:casa_case)
      assignment = create(:case_assignment, volunteer: volunteer, casa_case: casa_case)

      sign_in admin

      expect {
        delete volunteer_case_assignment_url(volunteer, assignment)
      }.to change(volunteer.casa_cases, :count).by(-1)

      expect(response).to redirect_to edit_volunteer_path(volunteer)
    end
  end
end
