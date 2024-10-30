require "rails_helper"

RSpec.describe ApplicationPolicy do
  subject { described_class }

  let(:casa_org) { build_stubbed :casa_org }
  let(:other_org) { build_stubbed :casa_org }

  let(:casa_admin) { build_stubbed :casa_admin, casa_org: }
  let(:supervisor) { build_stubbed :supervisor, casa_org: }
  let(:volunteer) { build_stubbed :volunteer, casa_org: }

  let(:other_org_casa_admin) { build_stubbed :casa_admin, casa_org: }
  let(:other_org_supervisor) { build_stubbed :supervisor, casa_org: }
  let(:other_org_volunteer) { build_stubbed :volunteer, casa_org: }

  let(:all_casa_admin) { build_stubbed :all_casa_admin }
  let(:nil_user) { nil }

  permissions :see_reports_page? do
    it "allows casa_admins and supervisors" do
      expect(subject).to permit(casa_admin)
      expect(subject).to permit(supervisor)

      expect(subject).not_to permit(volunteer)

      expect(subject).not_to permit(all_casa_admin)
      expect(subject).not_to permit(nil_user)
    end
  end

  permissions :see_import_page? do
    it "allows casa_admins" do
      expect(subject).to permit(casa_admin)

      expect(subject).not_to permit(supervisor)
      expect(subject).not_to permit(volunteer)

      expect(subject).not_to permit(all_casa_admin)
      expect(subject).not_to permit(nil_user)
    end
  end

  permissions :see_court_reports_page? do
    it "allows all User roles" do
      expect(subject).to permit(volunteer)
      expect(subject).to permit(casa_admin)
      expect(subject).to permit(supervisor)

      expect(subject).not_to permit(all_casa_admin)
      # expect(subject).not_to permit(nil_user) TODO
    end
  end

  permissions :see_emancipation_checklist? do
    it "allows volunteers" do
      expect(subject).to permit(volunteer)

      expect(subject).not_to permit(casa_admin)
      expect(subject).not_to permit(supervisor)

      expect(subject).not_to permit(all_casa_admin)
      # expect(subject).not_to permit(nil_user) TODO
    end
  end

  permissions :see_mileage_rate? do
    it "allows casa_admins" do
      expect(subject).to permit(casa_admin)

      expect(subject).not_to permit(volunteer)
      expect(subject).not_to permit(supervisor)

      expect(subject).not_to permit(all_casa_admin)
      expect(subject).not_to permit(nil_user)
    end

    context "when org reimbursement is disabled" do
      before do
        casa_org.show_driving_reimbursement = false
      end

      it "does not allow casa_admins" do
        expect(subject).not_to permit(casa_admin)
      end
    end
  end

  describe "#same_org?" do
    # could be any Model that has a :casa_org association, hence the doubles
    let(:org_record) { double }
    let(:other_org_record) { double }

    before do
      allow(org_record).to receive(:casa_org).and_return(casa_org)
      allow(other_org_record).to receive(:casa_org).and_return(other_org)
    end

    permissions :same_org? do
      it "allows User roles with same casa_org" do
        expect(subject).to permit(volunteer, org_record)
        expect(subject).to permit(supervisor, org_record)
        expect(subject).to permit(casa_admin, org_record)
        expect(subject).not_to permit(nil_user)

        expect(subject).not_to permit(volunteer, other_org_record)
        expect(subject).not_to permit(supervisor, other_org_record)
        expect(subject).not_to permit(casa_admin, other_org_record)
        expect(subject).not_to permit(nil_user)
      end
    end

    context "all_casa_admin user" do
      it "raises a no method error for all_casa_admin.casa_org" do
        expect { subject.new(all_casa_admin, org_record).same_org? }.to raise_error(NoMethodError)
      end
    end

    context "when called with a class instead of a record" do
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
