require "rails_helper"

RSpec.describe ApplicationPolicy do
  subject { described_class }

  let(:casa_org) { build_stubbed(:casa_org) }
  let(:casa_admin) { build_stubbed(:casa_admin, casa_org: casa_org) }
  let(:supervisor) { build_stubbed(:supervisor, casa_org: casa_org) }
  let(:volunteer) { build_stubbed(:volunteer, casa_org: casa_org) }
  let(:all_casa_admin) { build_stubbed(:all_casa_admin) }

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

  describe "#same_org?" do
    let(:org_record) { double }

    before { allow(org_record).to receive(:casa_org).and_return(casa_org) }

    context "record with same casa_org" do
      before { expect(org_record).to receive(:casa_org).and_return(casa_org) }

      permissions :same_org? do
        it { is_expected.to permit(volunteer, org_record) }
        it { is_expected.to permit(supervisor, org_record) }
        it { is_expected.to permit(casa_admin, org_record) }
      end
    end

    context "record with different casa_org" do
      let(:other_org_record) { double }
      before { expect(other_org_record).to receive(:casa_org).and_return(build_stubbed(:casa_org)) }

      permissions :same_org? do
        it { is_expected.to_not permit(volunteer, other_org_record) }
        it { is_expected.to_not permit(supervisor, other_org_record) }
        it { is_expected.to_not permit(casa_admin, other_org_record) }
      end
    end

    context "all_casa_admin user" do
      it "raises a no method error for all_casa_admin.casa_org" do
        expect { subject.new(all_casa_admin, org_record).same_org? }.to raise_error(NoMethodError)
      end
    end

    context "user with no casa_org" do
      let(:volunteer) { build_stubbed(:volunteer, casa_org: nil) }
      let(:supervisor) { build_stubbed(:supervisor, casa_org: nil) }
      let(:casa_admin) { build_stubbed(:casa_admin, casa_org: nil) }

      permissions :same_org? do
        it { is_expected.to_not permit(volunteer, org_record) }
        it { is_expected.to_not permit(supervisor, org_record) }
        it { is_expected.to_not permit(casa_admin, org_record) }
      end
    end

    context "no user" do
      let(:user) { nil }

      permissions :same_org? do
        it { is_expected.to_not permit(user, org_record) }
      end
    end

    context "called with a class instead of a record" do
      let(:klass) { CasaCase }

      [:volunteer, :casa_admin, :supervisor].each do |user_type|
        it "raises a no method error for #{user_type}" do
          user = send(user_type)
          expect { subject.new(user, klass).same_org? }.to raise_error(NoMethodError)
        end
      end
    end
  end
end
