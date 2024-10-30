require "rails_helper"

RSpec.describe CasaAdminPolicy do
  subject { described_class }

  let(:casa_org) { build_stubbed :casa_org }
  let(:other_casa_org) { build_stubbed :casa_org }

  let(:casa_admin) { build_stubbed :casa_admin, casa_org: }
  let(:supervisor) { build_stubbed :supervisor, casa_org: }
  let(:volunteer) { build_stubbed :volunteer, casa_org: }

  let(:org_casa_admin) { build_stubbed :casa_admin, casa_org: }
  let(:other_org_casa_admin) { build_stubbed :casa_admin, casa_org: other_casa_org }

  let(:all_casa_admin) { build_stubbed :all_casa_admin }
  let(:nil_user) { nil }

  permissions :edit? do
    it "allows admin of same org" do
      expect(subject).to permit(casa_admin, org_casa_admin)

      expect(subject).not_to permit(supervisor, org_casa_admin)
      expect(subject).not_to permit(volunteer, org_casa_admin)

      expect(subject).not_to permit(casa_admin, other_org_casa_admin)
      expect(subject).not_to permit(supervisor, other_org_casa_admin)
      expect(subject).not_to permit(volunteer, other_org_casa_admin)

      expect(subject).not_to permit(all_casa_admin, org_casa_admin)
      expect(subject).not_to permit(nil_user, org_casa_admin)
    end
  end

  permissions :index?, :activate?, :change_to_supervisor?, :create?, :datatable?, :new?, :resend_invitation?, :restore?, :update? do
    it "allows casa_admins" do
      expect(subject).to permit(casa_admin)

      expect(subject).not_to permit(supervisor)
      expect(subject).not_to permit(volunteer)

      expect(subject).not_to permit(all_casa_admin)
      expect(subject).not_to permit(nil_user)
    end
  end

  permissions :deactivate? do
    context "when user is a casa admin" do
      let(:casa_org) { create :casa_org }
      let(:casa_admin) { create :casa_admin, casa_org: }
      let(:admin_inactive) { create :casa_admin, active: false, casa_org: }

      it "does not permit if inactive or only active org admin" do
        expect(subject).not_to permit(admin_inactive, :casa_admin)
        expect(subject).not_to permit(casa_admin, :casa_admin)
      end

      it "permits if another casa admin exists" do
        create(:casa_admin, casa_org:)
        expect(subject).to permit(casa_admin)
      end
    end

    it "does not permit other than casa admin" do
      expect(subject).not_to permit(supervisor)
      expect(subject).not_to permit(volunteer)
    end
  end

  permissions :see_deactivate_option? do
    let(:inactive_admin) { build_stubbed :casa_admin, active: false, casa_org: }

    it "allows only active casa admins" do
      expect(subject).to permit(casa_admin)

      expect(subject).not_to permit(inactive_admin)

      expect(subject).not_to permit(supervisor)
      expect(subject).not_to permit(volunteer)

      expect(subject).not_to permit(all_casa_admin)
      expect(subject).not_to permit(nil_user)
    end
  end
end
