require "rails_helper"

RSpec.describe ReimbursementsController, type: :request do
  let(:admin) { create(:casa_admin) }
  let(:casa_org) { admin.casa_org }
  let(:case_contact) { create(:case_contact) }
  let(:notification_double) { double("ReimbursementCompleteNotification") }

  before do
    sign_in(admin)
    allow(ReimbursementCompleteNotification).to receive(:with).and_return(notification_double)
    allow(notification_double).to receive(:deliver)
  end

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
      expect(ReimbursementCompleteNotification).to(have_received(:with).once.with(case_contact: case_contact))
      expect(response).to redirect_to(reimbursements_path)
      expect(response).to have_http_status(:redirect)
      expect(case_contact.reload.reimbursement_complete).to be_truthy
    end
  end

  describe "PATCH /mark_as_needs_review" do
    before { case_contact.update(reimbursement_complete: true) }

    it "changes reimbursement status to needs review" do
      patch reimbursement_mark_as_needs_review_url(case_contact, case_contact: {reimbursement_complete: false})
      expect(response).to redirect_to(reimbursements_path)
      expect(response).to have_http_status(:redirect)
      expect(case_contact.reload.reimbursement_complete).to be_falsey
    end
  end
end
