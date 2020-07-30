require "rails_helper"

RSpec.describe "/case_assignments", type: :request do
  describe "POST /create" do
    context "when the volunteer has been previously assigned to the casa_case" do
      it "reassigns the volunteer to the casa_case" do
        admin = create(:user, :casa_admin)
        volunteer = create(:user, :volunteer)
        casa_case = create(:casa_case)
        assignment = create(:case_assignment, is_active: false, volunteer: volunteer, casa_case: casa_case)

        sign_in admin

        expect {
          post case_assignments_url(casa_case_id: casa_case.id),
            params: {case_assignment: {volunteer_id: volunteer.id}}
        }.to change { casa_case.case_assignments.first.is_active }.from(false).to(true)

        expect(response).to redirect_to edit_casa_case_path(casa_case)
      end
    end

    context "when the case assignment parent is a volunteer" do
      it "creates a new case assignment for the volunteer" do
        admin = create(:user, :casa_admin)
        volunteer = create(:user, :volunteer)
        casa_case = create(:casa_case)

        sign_in admin

        expect {
          post case_assignments_url(volunteer_id: volunteer.id),
            params: {case_assignment: {casa_case_id: casa_case.id}}
        }.to change(volunteer.casa_cases, :count).by(1)

        expect(response).to redirect_to edit_volunteer_path(volunteer)
      end
    end

    context "when the case assignment parent is a casa_case" do
      it "creates a new case assignment for the casa_case" do
        admin = create(:user, :casa_admin)
        volunteer = create(:user, :volunteer)
        casa_case = create(:casa_case)

        sign_in admin

        expect {
          post case_assignments_url(casa_case_id: casa_case.id),
            params: {case_assignment: {volunteer_id: volunteer.id}}
        }.to change(casa_case.volunteers, :count).by(1)

        expect(response).to redirect_to edit_casa_case_path(casa_case)
      end
    end
  end

  describe "DELETE /destroy" do
    context "when the case assignment parent is a volunteer" do
      it "destroys the case assignment from the volunteer" do
        admin = create(:user, :casa_admin)
        volunteer = create(:user, :volunteer)
        casa_case = create(:casa_case)
        assignment = create(:case_assignment, volunteer: volunteer, casa_case: casa_case)

        sign_in admin

        expect {
          delete case_assignment_url(assignment, volunteer_id: volunteer.id)
        }.to change(volunteer.casa_cases, :count).by(-1)

        expect(response).to redirect_to edit_volunteer_path(volunteer)
      end
    end

    context "when the case assignment parent is a casa_case" do
      it "destroys the case assignment from the casa_case" do
        admin = create(:user, :casa_admin)
        volunteer = create(:user, :volunteer)
        casa_case = create(:casa_case)
        assignment = create(:case_assignment, volunteer: volunteer, casa_case: casa_case)

        sign_in admin

        expect {
          delete case_assignment_url(assignment, casa_case_id: casa_case.id)
        }.to change(casa_case.volunteers, :count).by(-1)

        expect(response).to redirect_to edit_casa_case_path(casa_case)
      end
    end
  end
end
