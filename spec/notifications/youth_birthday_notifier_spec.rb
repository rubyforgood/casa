require "rails_helper"

RSpec.describe YouthBirthdayNotifier, type: :model do
  let(:casa_case) { create(:casa_case) }
  let(:notifier) { YouthBirthdayNotifier.with(casa_case: casa_case) }

  describe "title" do
    it "returns 'Youth Birthday Notification'" do
      expect(notifier.title).to eq "Youth Birthday Notification"
    end
  end

  describe "message" do
    it "contains the casa case number" do
      expect(notifier.message).to include casa_case.case_number
    end
  end

  describe "url" do
    it "returns the casa case path" do
      expect(notifier.url).to eq "/casa_cases/#{casa_case.id}"
    end
  end
end
