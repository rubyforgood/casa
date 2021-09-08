require "rails_helper"

RSpec.describe DashboardController, type: :controller do
  let(:organization) { create(:casa_org) }
  let(:volunteer) { create(:volunteer, casa_org: organization) }
  let(:admin) { create(:casa_admin) }
  let(:supervisor) { create(:supervisor) }
  let(:case_id) { volunteer.casa_cases.first.id }
  let(:inactive_case) { create :casa_case, :inactive }
  let(:active_case) { create :casa_case, :active }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
  end

  describe "get show" do
    subject { get :show }

    describe "as volunteer" do
      before do
        allow(controller).to receive(:current_user).and_return(volunteer)
      end

      context "with one active case" do
        let!(:case_assignment) { create :case_assignment, volunteer: volunteer, casa_case: active_case }

        it "goes to new case contact page" do
          is_expected.to redirect_to(new_case_contact_path)
        end
      end

      context "with two cases but one is inactive" do
        let!(:inactive_case_assignment) { create :case_assignment, volunteer: volunteer, casa_case: inactive_case }
        let!(:case_assignment) { create :case_assignment, volunteer: volunteer, casa_case: active_case }

        it "goes to new case contact page" do
          expect(subject).to redirect_to(new_case_contact_path)
        end
      end

      context "with two active cases" do
        let(:active_case2) { create :casa_case, :active }
        let!(:case_assignment) { create :case_assignment, volunteer: volunteer, casa_case: active_case }
        let!(:case_assignment2) { create :case_assignment, volunteer: volunteer, casa_case: active_case2 }

        it "goes to cases page" do
          is_expected.to redirect_to(casa_cases_url)
        end
      end
    end

    describe "as supervisor" do
      before do
        allow(controller).to receive(:current_user).and_return(supervisor)
      end

      it "goes to volunteers overview" do
        is_expected.to redirect_to(volunteers_url)
      end
    end

    describe "as admin" do
      before do
        allow(controller).to receive(:current_user).and_return(admin)
      end

      it "goes to supervisors overview" do
        is_expected.to redirect_to(supervisors_url)
      end
    end
  end
end
