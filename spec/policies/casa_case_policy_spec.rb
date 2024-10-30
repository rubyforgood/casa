require "rails_helper"

RSpec.describe CasaCasePolicy, :aggregate_failures do
  subject { described_class }

  let(:casa_org) { build :casa_org }
  let(:other_casa_org) { build_stubbed :casa_org }

  let(:casa_admin) { build_stubbed :casa_admin, casa_org: }
  let(:supervisor) { build_stubbed :supervisor, casa_org: }
  let(:volunteer) { build_stubbed :volunteer, casa_org: }
  let(:supervised_volunteer) { build_stubbed :volunteer, supervisor:, casa_org: }

  let(:casa_case) { build_stubbed :casa_case, casa_org: }
  let(:volunteer_casa_case) { build_stubbed :casa_case, volunteer:, casa_org: }
  let(:supervised_volunteer_casa_case) { build_stubbed :casa_case, volunteer: supervised_volunteer, casa_org: }

  let(:other_org_supervisor) { build_stubbed :supervisor, casa_org: other_casa_org }
  let(:other_org_volunteer) { build_stubbed :volunteer, supervisor: other_org_supervisor, casa_org: other_casa_org }

  let(:other_org_casa_case) { build_stubbed :casa_case, volunteer: other_org_volunteer, casa_org: other_casa_org }

  let(:all_casa_admin) { build_stubbed :all_casa_admin }
  let(:nil_user) { nil }

  permissions :index?, :save_emancipation? do
    it "allows all User roles" do
      expect(subject).to permit(casa_admin)
      expect(subject).to permit(supervisor)
      expect(subject).to permit(volunteer)

      expect(subject).not_to permit(all_casa_admin)
      expect(subject).not_to permit(nil_user)
    end
  end

  permissions :update_court_date?, :update_court_orders?, :update_court_report_due_date?, :update_hearing_type?, :update_judge? do
    it "allows all same org User roles" do
      expect(subject).to permit(casa_admin, casa_case)
      expect(subject).to permit(supervisor, casa_case)
      expect(subject).to permit(volunteer, casa_case)

      expect(subject).not_to permit(casa_admin, other_org_casa_case)
      expect(subject).not_to permit(supervisor, other_org_casa_case)
      expect(subject).not_to permit(volunteer, other_org_casa_case)

      expect(subject).not_to permit(all_casa_admin, casa_case)
      expect(subject).not_to permit(nil_user, casa_case)
    end
  end

  permissions :assign_volunteers?, :update_contact_types? do
    it "allows same org CasaAdmins and Supervisors" do
      expect(subject).to permit(casa_admin, casa_case)
      expect(subject).to permit(supervisor, casa_case)

      expect(subject).not_to permit(volunteer, casa_case)
      expect(subject).not_to permit(volunteer, volunteer_casa_case)

      expect(subject).not_to permit(casa_admin, other_org_casa_case)
      expect(subject).not_to permit(supervisor, other_org_casa_case)

      expect(subject).not_to permit(all_casa_admin, casa_case)
      expect(subject).not_to permit(nil_user, casa_case)
    end
  end

  permissions :edit?, :show?, :update?, :update_emancipation_option? do
    let(:casa_org) { create :casa_org }
    let(:volunteer) { create :volunteer, casa_org: }
    # build_stubbed didn't work: queries db for record.case_assignments
    let(:volunteer_casa_case) { create :casa_case, volunteer:, casa_org: }

    it "allows same org CasaAdmins/Supervisors, and Volunteers assigned to CasaCase" do
      expect(subject).to permit(casa_admin, casa_case)
      expect(subject).to permit(supervisor, casa_case)

      expect(subject).not_to permit(volunteer, casa_case)
      expect(subject).to permit(volunteer, volunteer_casa_case)

      expect(subject).not_to permit(casa_admin, other_org_casa_case)
      expect(subject).not_to permit(supervisor, other_org_casa_case)
      expect(subject).not_to permit(volunteer, other_org_casa_case)

      expect(subject).not_to permit(all_casa_admin, casa_case)
      expect(subject).not_to permit(nil_user, casa_case)
    end
  end

  permissions :new?, :create?, :destroy?, :update_case_number? do
    it "allows same org CasaAdmins" do
      expect(subject).to permit(casa_admin, casa_case)
      expect(subject).not_to permit(supervisor, casa_case)
      expect(subject).not_to permit(volunteer, casa_case)

      expect(subject).not_to permit(casa_admin, other_org_casa_case)

      expect(subject).not_to permit(all_casa_admin, casa_case)
      expect(subject).not_to permit(nil_user, casa_case)
    end
  end
end
