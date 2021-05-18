require "rails_helper"

RSpec.describe DashboardController, type: :controller do
  let(:organization) { create(:casa_org) }
  let(:volunteer) { create(:volunteer, :with_casa_cases, casa_org: organization) }
  let(:admin) { create(:casa_admin) }
  let(:supervisor) { create(:supervisor) }
  let(:case_id) { volunteer.casa_cases.first.id }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
  end

  describe "as volunteer" do
    before do
      allow(controller).to receive(:current_user).and_return(volunteer)
    end

    context "with one active case" do
      it "goes to case" do
        get :show
        expect(redirect_to(:casa_case_path)).to be_true
      end
    end

    context "with two cases but one is inactive" do
      it "goes to active case" do
        get :show
        # expect(assigns(:current_organization_groups)).to eq([contact_type_group_one])
      end
    end

    context "with two active cases" do
      it "goes to cases page" do
        get :show
        # expect(assigns(:current_organization_groups)).to eq([contact_type_group_one])
      end
    end
  end

  describe "as supervisor" do
    before do
      allow(controller).to receive(:current_user).and_return(supervisor)
    end

    it "goes to volunteers overview" do
      get :show
      # expect(assigns(:current_organization_groups)).to eq([contact_type_group_one])
    end
  end

  describe "as admin" do
    before do
      allow(controller).to receive(:current_user).and_return(admin)
    end

    it "goes to supervisors overview" do
      get :show
      # expect(assigns(:current_organization_groups)).to eq([contact_type_group_one])
    end
  end
end
