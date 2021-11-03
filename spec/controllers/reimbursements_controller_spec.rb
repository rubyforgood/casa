require "rails_helper"

RSpec.describe ReimbursementsController, type: :controller do
  let(:admin) { create(:casa_admin) }
  let(:casa_org) { admin.casa_org }

  before do
    allow(controller).to receive(:authenticate_user!).and_return(:admin)
  end

  describe "as admin" do
    before do
      allow(controller).to receive(:current_user).and_return(admin)
    end

    it "can see reimbursements page and excludes case contacts for a different org" do
      casa_case = create(:casa_case, casa_org: casa_org)
      case_contact = create(:case_contact, casa_case: casa_case, want_driving_reimbursement: true, miles_driven: 1, reimbursement_complete: false)
      other_org_casa_case = create(:casa_case, casa_org: create(:casa_org))
      _case_contact = create(:case_contact, casa_case: other_org_casa_case, want_driving_reimbursement: true, miles_driven: 2, reimbursement_complete: false)
      get :index
      expect(response).to render_template("index")
      expect(response).to have_http_status(:ok)
      expect(assigns(:reimbursements)).to eq([case_contact])
    end

    xit "can change reimbursement status to complete" do
      patch :mark_as_complete
      expect(response).to redirect_to(reimbursements_path)
      expect(response).to have_http_status(:redirect)
      expect(assigns(:reimbursements)).to eq([])
    end

    xit "can change reimbursement status to needs review" do
      patch :mark_as_needs_review
      expect(response).to redirect_to(reimbursements_path)
      expect(response).to have_http_status(:redirect)
      expect(assigns(:reimbursements)).to eq([])
    end
  end
end
