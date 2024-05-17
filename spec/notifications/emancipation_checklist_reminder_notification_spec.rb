require "rails_helper"

RSpec.describe EmancipationChecklistReminderNotifier, type: :model do
  let(:casa_case) { create :casa_case }

  let(:notification) { EmancipationChecklistReminderNotifier.with(casa_case: casa_case) }

  describe "message" do
    it "contains the case number" do
      case_number = casa_case.case_number
      expect(notification.message).to include case_number
    end
  end

  describe "url" do
    it "contains the case id" do
      case_id = casa_case.id.to_s
      expect(notification.url).to include case_id
    end
  end
end
