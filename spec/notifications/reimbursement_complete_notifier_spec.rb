require "rails_helper"

RSpec.describe ReimbursementCompleteNotifier, type: :model do
  describe "title" do
    it "returns 'Reimbursement Approved'" do
      case_contact = build(:case_contact, :wants_reimbursement)

      notification = ReimbursementCompleteNotifier.with(case_contact:)

      expect(notification.title).to eq("Reimbursement Approved")
    end
  end

  describe "message" do
    let(:case_contact) { create(:case_contact, :wants_reimbursement) }

    describe "with case org with nil mileage rate" do
      it "does not include reimbursement amount" do
        notification = ReimbursementCompleteNotifier.with(case_contact: case_contact)
        expect(notification.message).not_to include "$"
      end
    end

    describe "with casa org with active mileage rate" do
      let!(:mileage_rate) { create(:mileage_rate, casa_org: case_contact.casa_case.casa_org, amount: 6.50, effective_date: 3.days.ago) }

      it "does include reimbursement amount" do
        notification = ReimbursementCompleteNotifier.with(case_contact: case_contact)
        expect(notification.message).to include "$2964"
      end
    end
  end

  describe "url" do
    it "returns the case contacts URL path for the given case contact" do
      case_contact = create(:case_contact, :wants_reimbursement)

      notification = ReimbursementCompleteNotifier.with(case_contact:)

      expect(notification.url).to eq("/case_contacts?casa_case_id=#{case_contact.casa_case_id}")
    end
  end
end
