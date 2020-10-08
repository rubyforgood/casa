require "rails_helper"

RSpec.describe CasaAdminPolicy do
  subject { described_class }

  permissions :index? do
    let(:organization) { create(:casa_org) }
    let(:casa_admin) { create(:casa_admin, casa_org: organization) }
    let(:volunteer) { create(:volunteer, casa_org: organization) }
    let(:supervisor) { create(:supervisor, casa_org: organization) }

    it "allows casa_admins" do
      expect(subject).to permit(casa_admin)
    end

    it "allows supervisor" do
      expect(subject).to_not permit(supervisor)
    end

    it "allows supervisor" do
      expect(subject).to_not permit(volunteer)
    end
  end

  permissions :deactivate? do
    context "when user is a casa admin" do
      let(:admin) { create(:casa_admin, active: true) }
      let(:admin_inactive) { create(:casa_admin, active: false)}
      it 'permit if is a active user' do
        expect(subject).to permit(admin, :casa_admin)
      end

      it 'does permit if is a inactive user' do
        expect(subject).not_to permit(admin_inactive, :casa_admin)
      end
    end

    context "when user is a supervisor" do
      let(:supervisor) { create(:supervisor) }
      it 'does not permit' do
        expect(subject).not_to permit(supervisor, :casa_admin)
      end
    end

    context "when user is a volunteer" do
      let(:volunteer) { create(:volunteer) }
      it 'does not permit' do
        expect(subject).not_to permit(volunteer)
      end
    end
  end
end
