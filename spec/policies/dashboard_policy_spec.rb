require "rails_helper"

RSpec.describe DashboardPolicy do
  subject { described_class }

  permissions :show? do
    it "permits user to show" do
      expect(subject).to permit(create(:user))
    end
  end

  permissions :see_volunteers_section? do
    it "allows casa_admins" do
      expect(subject).to permit(create(:casa_admin))
    end

    it "does not allow volunteers" do
      expect(subject).not_to permit(create(:volunteer))
    end
  end

  permissions :create_cases_section? do
    context "when user is a volunteer with casa_cases" do
      it "permits user to see cases section" do
        volunteer = create(:volunteer)
        volunteer.casa_cases << create(:casa_case)
        expect(Pundit.policy(volunteer, :dashboard).create_case_contacts?).to eq true
      end
    end

    context "when user is a volunteer without casa_cases" do
      it "permits user to see cases section" do
        volunteer = create(:volunteer)
        expect(Pundit.policy(volunteer, :dashboard).create_case_contacts?).to eq false
      end
    end

    context "when user is an admin" do
      it "permits user to see cases section" do
        casa_admin = create(:casa_admin)
        expect(Pundit.policy(casa_admin, :dashboard).create_case_contacts?).to eq false
      end
    end
  end

  permissions :see_cases_section? do
    context "when user is a volunteer" do
      it "permits user to see cases section" do
        volunteer = create(:volunteer)
        expect(Pundit.policy(volunteer, :dashboard).see_cases_section?).to eq true
      end
    end
  end

  permissions :see_admins_section? do
    it "allows casa_admins" do
      expect(subject).to permit(create(:casa_admin))
    end

    it "does not allow supervisors" do
      expect(subject).not_to permit(create(:supervisor))
    end

    it "does not allow volunteers" do
      expect(subject).not_to permit(create(:volunteer))
    end
  end
end
