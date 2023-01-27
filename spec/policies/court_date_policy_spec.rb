require "rails_helper"

RSpec.describe CourtDatePolicy do
  subject { described_class }

  let(:organization) { create(:casa_org) }
  let(:different_organization) { create(:casa_org) }

  let(:court_date) { create(:court_date, casa_case: casa_case) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }

  let(:casa_admin) { create(:casa_admin, casa_org: organization) }
  let(:volunteer) { create(:volunteer, casa_org: organization) }
  let(:supervisor) { create(:supervisor, casa_org: organization) }

  permissions :show? do
    it { is_expected.to permit(casa_admin, court_date) }

    context "when a supervisor belongs to the same org as the case" do
      it { expect(subject).to permit(supervisor, court_date) }
    end

    context "when a supervisor does not belong to the same org as the case" do
      let(:casa_case) { create(:casa_case, casa_org: different_organization) }

      it { expect(subject).not_to permit(supervisor, court_date) }
    end

    context "when volunteer is assigned" do
      before { volunteer.casa_cases << casa_case }

      it { is_expected.to permit(volunteer, court_date) }
    end

    context "when volunteer is not assigned" do
      it { is_expected.not_to permit(volunteer, court_date) }
    end
  end

  permissions :destroy? do
    it { is_expected.to permit(casa_admin, court_date) }
    it { is_expected.to permit(supervisor, court_date) }
    it { is_expected.not_to permit(volunteer, court_date) }
  end
end
