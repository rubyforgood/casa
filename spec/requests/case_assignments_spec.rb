require 'rails_helper'

RSpec.describe '/case_assignments', type: :request do
  describe 'GET /index' do
    context 'with a volunteer signed in' do
      it 'redirects back to dashboard with an unauthorized notice' do
        volunteer = create(:user, :volunteer)
        sign_in volunteer

        get volunteer_case_assignments_path(volunteer)

        expect(response).to redirect_to(root_path)
      end
    end

    context 'with an admin signed in' do
      it 'renders a successful response' do
        admin = create(:user, :casa_admin)
        volunteer = create(:user, :volunteer)
        sign_in admin

        get volunteer_case_assignments_path(volunteer)

        expect(response).to be_successful
      end
    end
  end

  describe 'POST /create' do
    it 'creates a new case assignment' do
      admin = create(:user, :casa_admin)
      volunteer = create(:user, :volunteer)
      casa_case = create(:casa_case)

      sign_in admin

      expect do
        post volunteer_case_assignments_url(volunteer),
             params: { case_assignment: { casa_case_id: casa_case.id } }
      end.to change(volunteer.casa_cases, :count).by(1)

      expect(response).to redirect_to volunteer_case_assignments_path(volunteer)
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the case assignment' do
      admin = create(:user, :casa_admin)
      volunteer = create(:user, :volunteer)
      casa_case = create(:casa_case)
      assignment = create(:case_assignment, volunteer: volunteer, casa_case: casa_case)

      sign_in admin

      expect do
        delete volunteer_case_assignment_url(volunteer, assignment)
      end.to change(volunteer.casa_cases, :count).by(-1)

      expect(response).to redirect_to volunteer_case_assignments_path(volunteer)
    end
  end
end
