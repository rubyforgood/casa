require "rails_helper"

RSpec.describe ReimbursementsController, type: :request do
  let(:admin) { create(:casa_admin) }
  let(:case_contact) { create(:case_contact) }

  before do
    sign_in(admin)
  end

  describe "GET /index" do
    it "calls ReimbursementPolicy::Scope to filter reimbursements" do
      contact_relation = double(CaseContact)
      allow(contact_relation).to receive_message_chain(
        :want_driving_reimbursement,
        :created_max_ago,
        :filter_by_reimbursement_status
      ).and_return(CaseContact.none)
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

    it "sends a notification to the case_contact's creator" do
      expect do
        patch reimbursement_mark_as_complete_url(case_contact, case_contact: {reimbursement_complete: true})
      end.to change(Noticed::Notification, :count).by(1)

      notification = Noticed::Notification.last
      expect(notification.recipient).to eq(case_contact.creator)
    end

    context "when the case contact has a supervisor" do
      it "sends a notification to the case_contact's creator and supervisor" do
        supervisor = build(:supervisor)
        volunteer = build(:volunteer, supervisor:)
        case_contact = create(:case_contact, creator: volunteer)

        expect do
          patch reimbursement_mark_as_complete_url(case_contact, case_contact: {reimbursement_complete: true})
        end.to change(Noticed::Notification, :count).by(2)

        expect(Noticed::Notification.first.recipient).to eq(case_contact.creator)
        expect(Noticed::Notification.last.recipient).to eq(case_contact.supervisor)
      end
    end

    context "when reimbursement_complete arrives as the string \"1\" instead of a boolean" do
      # Default Rails checkboxes submit "1"/"0"; the boolean cast must handle this too.
      it "still sends a notification" do
        expect do
          patch reimbursement_mark_as_complete_url(case_contact, case_contact: {reimbursement_complete: "1"})
        end.to change(Noticed::Notification, :count).by(1)
      end
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

    it "does not send a notification" do
      expect do
        patch reimbursement_mark_as_needs_review_url(case_contact, case_contact: {reimbursement_complete: false})
      end.not_to change(Noticed::Notification, :count)
    end

    context "when reimbursement_complete arrives as the string \"0\" instead of a boolean" do
      # Mirror of the "1" case: "0" must cast to false, not a truthy string.
      it "still withholds the notification" do
        expect do
          patch reimbursement_mark_as_needs_review_url(case_contact, case_contact: {reimbursement_complete: "0"})
        end.not_to change(Noticed::Notification, :count)
      end
    end
  end
end
