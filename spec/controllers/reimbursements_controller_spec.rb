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

    it "calls ReimbursementPolicy::Scope to filter reimbursements" do
      contact_relation = double(CaseContact)
      allow(contact_relation).to receive_message_chain(
        :want_driving_reimbursement,
        :created_max_ago,
        :filter_by_reimbursement_status
      ).and_return([])
      allow(ReimbursementPolicy::Scope).to receive(:new)
        .with(controller.current_user, CaseContact.joins(:casa_case))
        .and_return(double(resolve: contact_relation))

      expect(contact_relation).to receive_message_chain(
        :want_driving_reimbursement,
        :created_max_ago,
        :filter_by_reimbursement_status
      )

      get :index

      expect(ReimbursementPolicy::Scope).to have_received(:new)
        .with(controller.current_user, CaseContact.joins(:casa_case))
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
