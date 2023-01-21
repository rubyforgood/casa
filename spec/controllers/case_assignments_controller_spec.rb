require "rails_helper"

RSpec.describe CaseAssignmentsController, type: :controller do
  let(:casa_org) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: casa_org) }
  let(:volunteer) { create(:volunteer, casa_org: casa_org) }
  let(:casa_case) { create(:casa_case, casa_org: casa_org) }

  describe "POST create" do
    context "when the volunteer has been previously assigned to the casa_case" do
      context "when request format is html" do
        it "reassigns the volunteer to the casa_case" do
          create(:case_assignment, active: false, volunteer: volunteer, casa_case: casa_case)
  
          sign_in admin
  
          expect {
            post :create, params: {casa_case_id: casa_case.id, case_assignment: {
              volunteer_id: volunteer.id
            }}
          }.to change { casa_case.case_assignments.first.active }.from(false).to(true)
  
          expect(response).to redirect_to edit_casa_case_path(casa_case)
        end
      end

      context "when request format is json" do
        it "reassigns the volunteer to the casa_case" do
          create(:case_assignment, active: false, volunteer: volunteer, casa_case: casa_case)
  
          sign_in admin
  
          expect {
            post :create, format: :json, params: {casa_case_id: casa_case.id, case_assignment: {
              volunteer_id: volunteer.id
            }}
          }.to change { casa_case.case_assignments.first.active }.from(false).to(true)
  
          expect(response.status).to eq 200
          expect(response.body).to eq "Volunteer reassigned to case"
        end
      end
    end

    context "when the case assignment parent is a volunteer" do
      context "when request format is html" do
        it "creates a new case assignment for the volunteer" do
          sign_in admin
  
          expect {
            post :create, params: {
              volunteer_id: volunteer.id, case_assignment: {casa_case_id: casa_case.id}
            }
          }.to change(volunteer.casa_cases, :count).by(1)
  
          expect(response).to redirect_to edit_volunteer_path(volunteer)
        end
      end

      context "when request format is json" do
        it "creates a new case assignment for the volunteer" do
          sign_in admin
  
          expect {
            post :create, format: :json, params: {
              volunteer_id: volunteer.id, case_assignment: {casa_case_id: casa_case.id}
            }
          }.to change(volunteer.casa_cases, :count).by(1)
  
          expect(response.status).to eq 200
          expect(response.body).to eq "Volunteer assigned to case"
        end
      end
    end

    context "when the case assignment parent is a casa_case" do
      context "when request format is html" do
        it "creates a new case assignment for the casa_case" do
          sign_in admin
  
          expect {
            post :create, params: {
              casa_case_id: casa_case.id, case_assignment: {volunteer_id: volunteer.id}
            }
          }.to change(casa_case.volunteers, :count).by(1)
  
          expect(response).to redirect_to edit_casa_case_path(casa_case)
        end
      end

      context "when request format is json" do
        it "creates a new case assignment for the casa_case" do
          sign_in admin
  
          expect {
            post :create, format: :json, params: {
              casa_case_id: casa_case.id, case_assignment: {volunteer_id: volunteer.id}
            }
          }.to change(casa_case.volunteers, :count).by(1)
  
          expect(response.status).to eq 200
          expect(response.body).to eq "Volunteer assigned to case"
        end
      end
    end

    context "when the case belongs to another organization" do
      it "does not create a case assignment" do
        other_org = build(:casa_org)
        other_casa_case = create(:casa_case, casa_org: other_org)

        sign_in admin

        expect {
          post :create, params: {
            casa_case_id: other_casa_case.id, case_assignment: {volunteer_id: volunteer.id}
          }
        }.not_to change(other_casa_case.volunteers, :count)
      end
    end

    context "when the volunteer belongs to another organization" do
      it "does not create a case assignment" do
        other_org = build_stubbed(:casa_org)
        other_volunteer = build_stubbed(:volunteer, casa_org: other_org)

        sign_in admin

        expect {
          post :create, params: {
            casa_case_id: casa_case.id, case_assignment: {volunteer_id: other_volunteer.id}
          }
        }.not_to change(casa_case.volunteers, :count)
      end
    end
  end

  describe "DELETE destroy" do
    context "when the case assignment parent is a volunteer" do
      it "destroys the case assignment from the volunteer" do
        assignment = create(:case_assignment, volunteer: volunteer, casa_case: casa_case)

        sign_in admin

        expect {
          delete :destroy, params: {
            id: assignment.id, volunteer_id: volunteer.id
          }
        }.to change(volunteer.casa_cases, :count).by(-1)

        expect(response).to redirect_to edit_volunteer_path(volunteer)
      end
    end

    context "when the case assignment parent is a casa_case" do
      it "destroys the case assignment from the casa_case" do
        assignment = create(:case_assignment, volunteer: volunteer, casa_case: casa_case)

        sign_in admin

        expect {
          delete :destroy, params: {
            id: assignment.id, casa_case_id: casa_case.id
          }
        }.to change(casa_case.volunteers, :count).by(-1)

        expect(response).to redirect_to edit_casa_case_path(casa_case)
      end
    end

    context "when the case belongs to another organization" do
      it "does not destroy the case assignment" do
        other_org = build(:casa_org)
        other_casa_case = create(:casa_case, casa_org: other_org)
        assignment = create(:case_assignment, casa_case: other_casa_case)

        sign_in admin

        expect {
          delete :destroy, params: {id: assignment.id, casa_case_id: other_casa_case.id}
        }.not_to change(other_casa_case.volunteers, :count).from(1)

        expect(response).to be_not_found
      end
    end
  end

  describe "PATCH unassign" do
    context "when redirect_to_path is volunteer" do
      it "deactivates the case assignment and redirects to edit volunteer" do
        assignment = create(:case_assignment, volunteer: volunteer)

        sign_in admin

        expect {
          patch :unassign, params: {id: assignment.id, redirect_to_path: "volunteer"}
        }.to change { assignment.reload.active? }.to(false)

        expect(response).to redirect_to edit_volunteer_path(volunteer)
      end
    end

    context "when redirect_to_path is not volunteer" do
      context "when request format is html" do
        it "deactivates the case assignment and redirects to edit casa case" do
          assignment = create(:case_assignment, casa_case: casa_case)

          sign_in admin

          expect {
            patch :unassign, params: {id: assignment.id}
          }.to change { assignment.reload.active? }.to(false)

          expect(response).to redirect_to edit_casa_case_path(casa_case)
        end
      end

      context "when request format is json" do
        it "deactivates the case assignment and returns success message" do
          assignment = create(:case_assignment, casa_case: casa_case)

          sign_in admin

          expect {
            patch :unassign, params: {id: assignment.id}, format: :json
          }.to change { assignment.reload.active? }.to(false)

          expect(response.status).to eq 200
          expect(response.body).to eq "Volunteer was unassigned from Case #{casa_case.case_number}."
        end
      end
    end

    context "when assignment belongs to another organization" do
      it "does not deactivate the case assignment" do
        assignment = create(:case_assignment)

        sign_in admin

        expect {
          patch :unassign, params: {id: assignment.id}
        }.not_to change { assignment.reload.active? }

        expect(response).to be_not_found
      end
    end
  end

  describe "PATCH show_hide_contacts" do
    context "when the 'case_assignment' is not active" do
      it "hides case contacts" do
        assignment = create(:case_assignment, casa_case: casa_case, active: false)

        sign_in admin

        expect {
          patch :show_hide_contacts, params: {id: assignment.id}
        }.to change { assignment.reload.hide_old_contacts? }

        expect(response).to redirect_to edit_casa_case_path(casa_case)
      end
    end
  end
end
