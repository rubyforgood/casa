require "rails_helper"

RSpec.describe DashboardPolicy do
  subject { described_class }

  permissions :show? do
    it "returns true" do
      expect(subject).to permit(create(:user))
    end
  end

  permissions :see_volunteers_section? do
    it "allows casa_admins" do
      expect(subject).to permit(create(:user, :casa_admin))
    end

    it "does not allow volunteers" do
      expect(subject).not_to permit(create(:user, :volunteer))
    end
  end

  permissions :see_cases_section? do
    it "returns true" do
      expect(subject).to permit(create(:user))
    end
  end
end
