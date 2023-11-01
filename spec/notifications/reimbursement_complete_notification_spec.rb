require "rails_helper"

RSpec.describe ReimbursementCompleteNotification, type: :model do
  describe "message" do
    let(:case_contact) { build(:case_contact, :wants_reimbursement) }

    describe "with case org with nil mileage rate" do
      it "does not include reimbursement amount" do
        notification = ReimbursementCompleteNotification.with(case_contact: case_contact)
        expect(notification.message).not_to include "$"
      end
    end

    describe "with casa org with active mileage rate" do
      let!(:mileage_rate) { create(:mileage_rate, casa_org: case_contact.casa_case.casa_org, amount: 6.50, effective_date: 3.days.ago) }

      it "does include reimbursement amount" do
        notification = ReimbursementCompleteNotification.with(case_contact: case_contact)
        expect(notification.message).to include "$2964"
      end
    end
  end
end
