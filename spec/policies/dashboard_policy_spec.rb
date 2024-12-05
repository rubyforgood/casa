require "rails_helper"

RSpec.describe DashboardPolicy do
  subject { described_class }

  let(:user) { build(:user) }
  let(:casa_admin) { build(:casa_admin) }
  let(:supervisor) { build(:supervisor) }
  let(:volunteer) { build(:volunteer) }

  permissions :show? do
    it "permits user to show" do
      expect(subject).to permit(user)
    end
  end

  permissions :see_volunteers_section? do
    it "allows casa_admins" do
      expect(subject).to permit(casa_admin)
    end

    it "does not allow volunteers" do
      expect(subject).not_to permit(volunteer)
    end
  end

  permissions :create_cases_section? do
    context "when user is a volunteer with casa_cases" do
      it "permits user to see cases section" do
        volunteer.casa_cases << build_stubbed(:casa_case, casa_org: volunteer.casa_org)
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
        expect(subject).to permit(volunteer, :dashboard)
      end
    end
  end

  permissions :see_admins_section? do
    it "allows casa_admins" do
      expect(subject).to permit(casa_admin)
    end

    it "does not allow supervisors and volunteers" do
      expect(subject).not_to permit(supervisor)
    end

    it "does not allow volunteers" do
      expect(subject).not_to permit(volunteer)
    end
  end
end
