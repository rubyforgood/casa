require "rails_helper"

RSpec.describe FollowupPolicy do
  subject { described_class }

  let(:casa_admin) { build_stubbed(:casa_admin) }
  let(:volunteer) { build_stubbed(:volunteer) }
  let(:supervisor) { build_stubbed(:supervisor) }

  permissions :create? do
    it "allows casa_admins" do
      expect(subject).to permit(casa_admin)
    end

    it "allows supervisor" do
      expect(subject).to permit(supervisor)
    end

    it "allows volunteer" do
      expect(subject).to permit(volunteer)
    end
  end

  permissions :resolve? do
    let(:casa_org) { create(:casa_org) }
    let(:followup) { create(:followup, case_contact: create(:case_contact, casa_case: create(:casa_case, casa_org: casa_org))) }
    let(:other_org_followup) { create(:followup, case_contact: create(:case_contact, casa_case: create(:casa_case, casa_org: create(:casa_org)))) }

    %i[casa_admin supervisor volunteer].each do |role|
      it "permits a #{role} in the followup's org" do
        expect(subject).to permit(create(role, casa_org: casa_org), followup)
      end

      it "does not permit a #{role} from another org" do
        expect(subject).not_to permit(create(role, casa_org: casa_org), other_org_followup)
      end
    end
  end
end
