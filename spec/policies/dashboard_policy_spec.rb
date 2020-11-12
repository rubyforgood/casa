require "rails_helper"

RSpec.describe DashboardPolicy do
  subject { described_class }

  let(:user) { create(:user) }
  let(:casa_admin) { create(:casa_admin) }
  let(:supervisor) { create(:supervisor) }
  let(:volunteer) { create(:volunteer) }

  permissions :show? do
    it "permits user to show" do
      is_expected.to permit(user)
    end
  end

  permissions :see_volunteers_section? do
    it "allows casa_admins" do
      is_expected.to permit(casa_admin)
    end

    it "does not allow volunteers" do
      is_expected.not_to permit(volunteer)
    end
  end

  permissions :create_cases_section? do
    context "when user is a volunteer with casa_cases" do
      it "permits user to see cases section" do
        volunteer.casa_cases << create(:casa_case, casa_org: volunteer.casa_org)
        expect(Pundit.policy(volunteer, :dashboard).create_case_contacts?).to eq true
      end
    end

    context "when user is a volunteer without casa_cases" do
      it "permits user to see cases section" do
        expect(Pundit.policy(volunteer, :dashboard).create_case_contacts?).to eq false
      end
    end

    context "when user is an admin" do
      it "permits user to see cases section" do
        expect(Pundit.policy(casa_admin, :dashboard).create_case_contacts?).to eq false
      end
    end
  end

  permissions :see_cases_section? do
    context "when user is a volunteer" do
      it "permits user to see cases section" do
        is_expected.to permit(volunteer, :dashboard)
      end
    end
  end

  permissions :see_admins_section? do
    it "allows casa_admins" do
      is_expected.to permit(casa_admin)
    end

    it "does not allow supervisors and volunteers" do
      is_expected.not_to permit(supervisor)
    end

    it "does not allow volunteers" do
      is_expected.not_to permit(volunteer)
    end
  end
end
