require "rails_helper"

RSpec.describe InactiveMessagesService do
  describe "#inactive_messages" do
    subject { described_class.new(supervisor).inactive_messages }

    let(:supervisor) { create :supervisor }

    it "has messages" do
      v1 = create(:supervisor_volunteer, supervisor: supervisor).volunteer
      create(:case_assignment, :inactive, volunteer: v1, casa_case: create(:casa_case, case_number: "ABC"))
      create(:case_assignment, :inactive, volunteer: v1, casa_case: create(:casa_case, case_number: "DEF"))
      create(:case_assignment, volunteer: v1, casa_case: create(:casa_case, case_number: "active-case"))
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
