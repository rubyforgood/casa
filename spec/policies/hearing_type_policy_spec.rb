require "rails_helper"

RSpec.describe HearingTypePolicy do
  subject { described_class }

  let(:casa_org) { build_stubbed(:casa_org) }
  let(:casa_admin) { build_stubbed(:casa_admin, casa_org:) }
  let(:volunteer) { build_stubbed(:volunteer, casa_org:) }
  let(:supervisor) { build_stubbed(:supervisor, casa_org:) }

  permissions :new?, :create?, :edit?, :update? do
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
    subject { described_class::Scope.new(casa_admin, HearingType.all).resolve }

    let(:casa_org) { create(:casa_org) }
    let(:casa_admin) { create(:casa_admin, casa_org:) }

    it "onlies return hearing types that belong to a given casa organization" do
      hearing_type_1 = create(:hearing_type, casa_org:)
      hearing_type_2 = create(:hearing_type, casa_org:)

      casa_org_2 = create(:casa_org)
      hearing_type_3 = create(:hearing_type, name: "unwanted hearing type", casa_org: casa_org_2)

      expect(subject).to contain_exactly(hearing_type_1, hearing_type_2)
      expect(subject).not_to include hearing_type_3
    end
  end
end
