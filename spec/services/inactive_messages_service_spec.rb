require "rails_helper"

RSpec.describe InactiveMessagesService do
  describe "#inactive_messages" do
    subject { described_class.new(supervisor).inactive_messages }

    let(:casa_org) { create :casa_org }
    let(:supervisor) { create :supervisor, casa_org: }

    it "has messages" do
      v1 = create(:volunteer, supervisor:, casa_org:)
      create(:case_assignment, :inactive, volunteer: v1, casa_case: create(:casa_case, case_number: "ABC", casa_org:))
      create(:case_assignment, :inactive, volunteer: v1, casa_case: create(:casa_case, case_number: "DEF", casa_org:))
      create(:case_assignment, volunteer: v1, casa_case: create(:casa_case, case_number: "active-case", casa_org:))
      create(:supervisor_volunteer, supervisor: supervisor)
      expect(subject.count).to eq(2)
      expect(subject.first).to match(/Case .* marked inactive this week./)
      expect(subject.first).to match(/Case .* marked inactive this week./)
    end

    it "has no messages" do
      expect(subject).to eq([])
    end
  end
end
