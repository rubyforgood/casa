require "rails_helper"

RSpec.describe "/emancipation_checklists", type: :request do
  describe "GET /index" do
    before { sign_in volunteer }

    context "when viewing the page as a volunteer" do
      let(:volunteer) { build(:volunteer) }

      context "when viewing the page with exactly one transitioning case" do
        let(:casa_case) { build(:casa_case, casa_org: volunteer.casa_org) }
        let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }

        it "redirects to the emancipation checklist page for that case" do
          get emancipation_checklists_path
          expect(response).to redirect_to(casa_case_emancipation_path(casa_case))
        end
      end

      context "when viewing the page with zero transitioning cases" do
        it "renders a successful response" do
          get emancipation_checklists_path
          expect(response).to be_successful
        end
      end

      context "when viewing the page with more than one transitioning cases" do
        let(:casa_case_a) { build(:casa_case, casa_org: volunteer.casa_org) }
        let(:casa_case_b) { build(:casa_case, casa_org: volunteer.casa_org) }
        let!(:case_assignment_a) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case_a) }
        let!(:case_assignment_b) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case_b) }

        it "renders a successful response" do
          get emancipation_checklists_path
          expect(response).to be_successful
        end

        it "filters the list to the searched case number" do
          get emancipation_checklists_path(search: casa_case_a.case_number)
          expect(response).to be_successful
          expect(response.body).to include(casa_case_emancipation_path(casa_case_a))
          expect(response.body).not_to include(casa_case_emancipation_path(casa_case_b))
        end
      end
    end
  end
end
