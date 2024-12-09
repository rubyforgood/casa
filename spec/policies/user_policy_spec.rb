require "rails_helper"

RSpec.describe UserPolicy do
  subject { described_class }

  let(:org_a) { build_stubbed(:casa_org) }
  let(:org_b) { build_stubbed(:casa_org) }

  let(:casa_admin_a) { build_stubbed(:casa_admin, casa_org: org_a) }
  let(:casa_admin_b) { build_stubbed(:casa_admin, casa_org: org_b) }
  let(:supervisor_a) { build_stubbed(:supervisor, casa_org: org_a) }
  let(:supervisor_b) { build_stubbed(:supervisor, casa_org: org_b) }
  let(:volunteer_a) { build_stubbed(:volunteer, casa_org: org_a) }
  let(:volunteer_b) { build_stubbed(:volunteer, casa_org: org_b) }

  permissions :edit?, :update?, :update_password? do
    it "allows casa_admins" do
      expect(subject).to permit(casa_admin_a)
    end

    it "allows supervisor" do
      expect(subject).to permit(supervisor_a)
    end

    it "allows volunteer" do
      expect(subject).to permit(volunteer_a)
    end
  end

  permissions :update_user_setting? do
    context "when user is an admin" do
      it "allows update settings of all roles" do
        expect(subject).to permit(casa_admin_a)
        expect(subject).to permit(casa_admin_b)
      end
    end

    context "when user is a supervisor" do
      it "allows supervisors to update another volunteer settings in their casa org" do
        expect(subject).to permit(supervisor_a, volunteer_a)
        expect(subject).to permit(supervisor_b, volunteer_b)
      end

      it "does not allow supervisor to update a volunteer in a different casa org" do
        expect(subject).not_to permit(supervisor_a, volunteer_b)
        expect(subject).not_to permit(supervisor_b, volunteer_a)
      end

      it "allows supervisors to update their own settings" do
        expect(subject).to permit(supervisor_a, supervisor_a)
        expect(subject).to permit(supervisor_b, supervisor_b)
      end

      it "does not allow supervisor to update another supervisor settings" do
        expect(subject).not_to permit(supervisor_a, supervisor_b)
        expect(subject).not_to permit(supervisor_b, supervisor_a)
      end
    end
  end

  permissions :add_language? do
    context "when user is a volunteer" do
      it "allows volunteer to add a language to themselves" do
        expect(subject).to permit(volunteer_a, volunteer_a)
        expect(subject).to permit(volunteer_b, volunteer_b)
      end

      it "does not allow another volunteer to add a language to another volunteer" do
        expect(subject).not_to permit(volunteer_a, volunteer_b)
        expect(subject).not_to permit(volunteer_b, volunteer_a)
      end
    end

    context "when user is a supervisor" do
      it "allows supervisors to add a language to a volunteer in their organizations" do
        expect(subject).to permit(supervisor_a, volunteer_a)
        expect(subject).to permit(supervisor_b, volunteer_b)
      end

      it "does not allow a supervisor to add a language to a volunteer in a different organization" do
        expect(subject).not_to permit(supervisor_a, volunteer_b)
        expect(subject).not_to permit(supervisor_b, volunteer_a)
      end
    end

    context "when user is an admin" do
      it "allows admins to add a language to a volunteer in their organizations" do
        expect(subject).to permit(casa_admin_a, volunteer_a)
        expect(subject).to permit(casa_admin_b, volunteer_b)
      end

      it "does not allow an admin to add a language to a volunteer in a different organization" do
        expect(subject).not_to permit(casa_admin_a, volunteer_b)
        expect(subject).not_to permit(casa_admin_b, volunteer_a)
      end
    end
  end
end
