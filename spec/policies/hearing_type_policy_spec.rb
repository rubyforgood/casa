require "rails_helper"

RSpec.describe HearingTypePolicy do
  subject { described_class }

  let(:casa_admin) { build_stubbed(:casa_admin) }
  let(:volunteer) { build_stubbed(:volunteer) }
  let(:supervisor) { build_stubbed(:supervisor) }

  permissions :new?, :create? do
    it "allows casa_admins" do
      expect(subject).to permit(casa_admin)
    end

    it "does not permit supervisor" do
      expect(subject).not_to permit(supervisor)
    end

    it "does not permit volunteer" do
      expect(subject).not_to permit(volunteer)
    end
  end

  describe "scope" do
    it "onlies return hearing types that belong to a given casa organization" do
      hearing_type_1 = create(:hearing_type)
      hearing_type_2 = create(:hearing_type)

      hearing_type_3 = create(:hearing_type)
      casa_org_2 = create(:casa_org)
      hearing_type_3.update_attribute(:casa_org_id, casa_org_2.id)
      hearing_type_3.update_attribute(:name, "unwanted hearing type")

      scoped_hearing_types = Pundit.policy_scope!(create(:casa_admin), HearingType).to_a
      expect(scoped_hearing_types).to contain_exactly(hearing_type_1, hearing_type_2)
    end
  end

  permissions :edit?, :update? do
    let(:casa_org) { create(:casa_org) }
    let(:admin) { create(:casa_admin, casa_org: casa_org) }

    it "allows casa_admins in the record's org" do
      expect(subject).to permit(admin, create(:hearing_type, casa_org: casa_org))
    end

    it "does not permit casa_admins from another org" do
      expect(subject).not_to permit(admin, create(:hearing_type, casa_org: create(:casa_org)))
    end

    it "does not permit supervisors or volunteers" do
      record = create(:hearing_type, casa_org: casa_org)
      expect(subject).not_to permit(create(:supervisor, casa_org: casa_org), record)
      expect(subject).not_to permit(create(:volunteer, casa_org: casa_org), record)
    end
  end
end
