require "rails_helper"

RSpec.describe PlacementPolicy do
  subject { described_class }

  let(:casa_org) { create(:casa_org) }
  let(:diff_org) { create(:casa_org) }

  let(:casa_case) { create(:casa_case, casa_org:) }
  let(:placement) { create(:placement, casa_case:) }

  let(:casa_admin) { build(:casa_admin, casa_org:) }
  let(:supervisor) { build(:supervisor, casa_org:) }
  let(:volunteer) { build(:volunteer, casa_org:) }
  let(:casa_admin_diff_org) { build(:casa_admin, casa_org: diff_org) }
  let(:supervisor_diff_org) { build(:supervisor, casa_org: diff_org) }
  let(:volunteer_diff_org) { build(:volunteer, casa_org: diff_org) }

  permissions :create?, :edit?, :update?, :show?, :new? do
    it { is_expected.to permit(casa_admin, placement) }

    context "when a supervisor belongs to the same org as the case" do
      it { expect(subject).to permit(supervisor, placement) }
    end

    context "when a supervisor does not belong to the same org as the case" do
      let(:casa_case) { create(:casa_case, casa_org: diff_org) }

      it { expect(subject).not_to permit(supervisor, placement) }
    end

    context "when volunteer is assigned" do
      before { create(:case_assignment, volunteer:, casa_case:, active: true) }

      it { is_expected.to permit(volunteer, placement) }
    end

    context "when volunteer is not assigned" do
      it { is_expected.not_to permit(volunteer, placement) }
    end
  end

  permissions :destroy? do
    it { is_expected.to permit(casa_admin, placement) }
    it { is_expected.to permit(supervisor, placement) }
    it { is_expected.not_to permit(volunteer, placement) }
  end
end
