require "rails_helper"

RSpec.describe ReimbursementsController, type: :request do
  let(:admin) { create(:casa_admin) }
  let(:casa_org) { admin.casa_org }

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
end
