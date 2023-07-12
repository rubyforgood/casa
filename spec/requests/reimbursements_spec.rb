require "rails_helper"

RSpec.describe ReimbursementsController, type: :request do
  let(:admin) { create(:casa_admin) }
  let(:casa_org) { admin.casa_org }
  let(:case_contact) { create(:case_contact) }

  before { sign_in(admin) }

  describe "GET /index" do
    it "calls ReimbursementPolicy::Scope to filter reimbursements" do
      contact_relation = double(CaseContact)
      allow(contact_relation).to receive_message_chain(
        :want_driving_reimbursement,
        :created_max_ago,
        :filter_by_reimbursement_status
      ).and_return([])
      allow(ReimbursementPolicy::Scope).to receive(:new)
        .with(admin, CaseContact.joins(:casa_case))
        .and_return(double(resolve: contact_relation))

      expect(contact_relation).to receive_message_chain(
        :want_driving_reimbursement,
        :created_max_ago,
        :filter_by_reimbursement_status
      )

      get reimbursements_url

      expect(ReimbursementPolicy::Scope).to have_received(:new)
        .with(admin, CaseContact.joins(:casa_case))
    end
  end

  describe "PATCH /mark_as_complete" do
    it "changes reimbursement status to complete" do
      patch reimbursement_mark_as_complete_url(case_contact, case_contact: {reimbursement_complete: true})
      expect(response).to redirect_to(reimbursements_path)
      expect(response).to have_http_status(:redirect)
      expect(case_contact.reload.reimbursement_complete).to be_truthy
    end
  end
end
