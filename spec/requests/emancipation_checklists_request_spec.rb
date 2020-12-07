require "rails_helper"

RSpec.describe "/emancipation_checklists", type: :request do
  let(:organization) { create(:casa_org) }

  describe "GET /index" do
    before { sign_in volunteer }

    context "when viewing the page as a volunteer" do
      let(:volunteer) { create(:volunteer, casa_org: organization) }

      context "when viewing the page with exactly one transitioning case" do
        let(:casa_case) { create(:casa_case, casa_org: organization, transition_aged_youth: true) }
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
        let(:casa_case_a) { create(:casa_case, casa_org: organization, transition_aged_youth: true) }
        let(:casa_case_b) { create(:casa_case, casa_org: organization, transition_aged_youth: true) }
        let!(:case_assignment_a) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case_a) }
        let!(:case_assignment_b) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case_b) }

        it "renders a successful response" do
          get emancipation_checklists_path
          expect(response).to be_successful
        end
      end
    end
  end
end
