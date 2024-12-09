require "rails_helper"

RSpec.describe "/dashboard", type: :request do
  let(:organization) { create(:casa_org) }

  context "as a volunteer" do
    let(:volunteer) { create(:volunteer, casa_org: organization) }
    let!(:case_assignment) { create(:case_assignment, volunteer: volunteer) }

    before do
      sign_in volunteer
    end

    describe "GET /show" do
      context "with one active case" do
        it "redirects to the new case contact" do
          get root_url

          expect(response).to redirect_to(new_case_contact_path)
        end
      end

      context "more than one active case" do
        let!(:active_case_assignment) { create :case_assignment, volunteer: volunteer }

        it "renders a successful response" do
          get root_url

          expect(response).to redirect_to(casa_cases_path)
        end

        it "shows my cases" do
          get root_url
          follow_redirect!

          expect(response.body).to include(active_case_assignment.casa_case.case_number)
          expect(response.body).to include(case_assignment.casa_case.case_number)
        end

        it "doesn't show other volunteers' cases" do
          not_logged_in_volunteer = create(:volunteer)
          create(:case_assignment, volunteer: not_logged_in_volunteer)

          get root_url
          follow_redirect!

          expect(response.body).to include(active_case_assignment.casa_case.case_number)
          expect(response.body).to include(case_assignment.casa_case.case_number)
          expect(response.body).not_to include(not_logged_in_volunteer.casa_cases.first.case_number)
        end

        it "doesn't show other organizations' cases" do
          different_org = create(:casa_org)
          not_my_case_assignment = create(:case_assignment, casa_org: different_org)

          get root_url
          follow_redirect!

          expect(response.body).to include(active_case_assignment.casa_case.case_number)
          expect(response.body).to include(case_assignment.casa_case.case_number)
          expect(response.body).not_to include(not_my_case_assignment.casa_case.case_number)
        end
      end
    end
  end

  context "as a supervisor" do
    let(:supervisor) { create(:supervisor, casa_org: organization) }

    before do
      sign_in supervisor
    end

    describe "GET /show" do
      it "redirects to the volunteers overview" do
        get root_url

        expect(response).to redirect_to(volunteers_url)
      end
    end
  end

  context "as an admin" do
    let(:admin) { create(:casa_admin, casa_org: organization) }

    before do
      sign_in admin
    end

    describe "GET /show" do
      it "renders a successful response" do
        get root_url

        expect(response).to redirect_to(supervisors_path)
      end
    end
  end
end
