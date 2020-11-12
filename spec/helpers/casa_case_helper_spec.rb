require "rails_helper"

RSpec.describe CasaCaseHelper do
  let(:casa_org) { create(:casa_org) }
  let(:volunteer1) { create(:volunteer, casa_org: casa_org) }
  let(:volunteer2) { create(:volunteer, casa_org: casa_org) }
  let!(:case_assignment1) { create(:case_assignment, casa_case: casa_case, is_active: false, volunteer: volunteer1) }
  let!(:case_assignment2) { create(:case_assignment, casa_case: casa_case, is_active: true, volunteer: volunteer2) }
  let(:casa_case) { create(:casa_case, casa_org: casa_org) }

  describe "#assigned_volunteers" do
    it "returns an array of volunteers assigned to a case" do
      expect(assigned_volunteers(casa_case)).to eq([volunteer2])
    end

    context "when case assignment is not active" do
      let(:casa_case1) { create(:casa_case, casa_org: casa_org, case_assignments: [case_assignment1]) }

      it "returns an empty array" do
        expect(assigned_volunteers(casa_case1)).to eq([])
      end
    end

    context "when case has no assignments" do
      let(:casa_case2) { create(:casa_case, casa_org: casa_org) }

      it "returns an empty array" do
        expect(assigned_volunteers(casa_case2)).to eq([])
      end
    end
  end
end
