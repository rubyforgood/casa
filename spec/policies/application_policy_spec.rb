require "rails_helper"

RSpec.describe ApplicationPolicy do
  subject { described_class }

  permissions :see_reports_page? do
    it "allows casa_admins" do
      expect(subject).to permit(create(:casa_admin))
    end

    it "allows supervisors" do
      expect(subject).to permit(create(:supervisor))
    end

    it "does not allow volunteers" do
      expect(subject).not_to permit(create(:volunteer))
    end
  end

  permissions :see_import_page? do
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
