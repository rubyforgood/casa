require "rails_helper"

RSpec.describe ApplicationPolicy do
  subject { described_class }

  let(:casa_admin) { create(:casa_admin) }
  let(:supervisor) { create(:supervisor) }
  let(:volunteer) { create(:volunteer) }

  permissions :see_reports_page? do
    it "allows casa_admins" do
      is_expected.to permit(casa_admin)
    end

    it "allows supervisors" do
      is_expected.to permit(supervisor)
    end

    it "does not allow volunteers" do
      is_expected.not_to permit(volunteer)
    end
  end

  permissions :see_import_page? do
    it "allows casa_admins" do
      is_expected.to permit(casa_admin)
    end

    it "does not allow supervisors" do
      is_expected.not_to permit(supervisor)
    end

    it "does not allow volunteers" do
      is_expected.not_to permit(volunteer)
    end
  end

  permissions :see_court_reports_page? do
    it "allows volunteers" do
      expect(subject).to permit(create(:volunteer))
    end

    it "does not allow casa_admins" do
      expect(subject).not_to permit(create(:casa_admin))
    end

    it "does not allow supervisors" do
      expect(subject).not_to permit(create(:supervisor))
    end
  end

  permissions :see_emancipation_checklist? do
    it "allows volunteers" do
      expect(subject).to permit(create(:volunteer))
    end

    it "does not allow casa_admins" do
      expect(subject).not_to permit(create(:casa_admin))
    end

    it "does not allow supervisors" do
      expect(subject).not_to permit(create(:supervisor))
    end
  end
end
