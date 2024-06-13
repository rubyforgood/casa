require "rails_helper"

RSpec.describe OtherDutyPolicy do
  subject { described_class }

  let(:casa_admin) { build_stubbed(:casa_admin) }
  let(:supervisor) { build_stubbed(:supervisor) }
  let(:volunteer) { build_stubbed(:volunteer) }

  permissions :index? do
    it "allows casa_admins" do
      is_expected.to permit(casa_admin)
    end

    it "allows supervisors" do
      is_expected.to permit(supervisor)
    end

    it "allows volunteer" do
      is_expected.to permit(volunteer)
    end

    context "when other_duties_enabled is false in casa_org" do
      before do
        casa_admin.casa_org.other_duties_enabled = false
        supervisor.casa_org.other_duties_enabled = false
        volunteer.casa_org.other_duties_enabled = false
      end
      it "not allows casa_admins" do
        is_expected.not_to permit(casa_admin)
      end

      it "not allows supervisors" do
        is_expected.not_to permit(supervisor)
      end

      it "not allows volunteer" do
        is_expected.not_to permit(volunteer)
      end
    end
    context "when other_duties_enabled is true in casa_org" do
      before do
        casa_admin.casa_org.other_duties_enabled = true
        supervisor.casa_org.other_duties_enabled = true
        volunteer.casa_org.other_duties_enabled = true
      end
      it "not allows casa_admins" do
        is_expected.to permit(casa_admin)
      end

      it "not allows supervisors" do
        is_expected.to permit(supervisor)
      end

      it "not allows volunteer" do
        is_expected.to permit(volunteer)
      end
    end
  end
end
