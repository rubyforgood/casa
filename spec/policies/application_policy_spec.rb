require "rails_helper"

RSpec.describe ApplicationPolicy do
  subject { described_class }

  let(:casa_org) { build_stubbed(:casa_org) }
  let(:casa_admin) { build_stubbed(:casa_admin, casa_org: casa_org) }
  let(:supervisor) { build_stubbed(:supervisor, casa_org: casa_org) }
  let(:volunteer) { build_stubbed(:volunteer, casa_org: casa_org) }

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

    it "allows casa_admins" do
      expect(subject).to permit(create(:casa_admin))
    end

    it "allows supervisors" do
      expect(subject).to permit(create(:supervisor))
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

  permissions :see_mileage_rate? do
    it "does not allow volunters" do
      is_expected.not_to permit(volunteer)
    end

    it "does not allow supervisors" do
      is_expected.not_to permit(supervisor)
    end

    it "allow casa_admins for same org" do
      is_expected.to permit(casa_admin)
    end

    context "when org reimbursement is disabled" do
      before do
        casa_org.show_driving_reimbursement = false
      end

      it "does not allow casa_admins" do
        is_expected.not_to permit(casa_admin)
      end
    end
  end
end
