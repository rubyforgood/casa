require "rails_helper"

RSpec.describe UserPolicy do
  subject { described_class }

  let(:casa_admin) { build_stubbed(:casa_admin) }
  let(:volunteer) { build_stubbed(:volunteer) }
  let(:supervisor) { build_stubbed(:supervisor) }

  let(:org_b) { build_stubbed(:casa_org) }
  let(:casa_admin_b) { build_stubbed(:casa_admin, casa_org: org_b) }
  let(:supervisor_b) { build_stubbed(:supervisor, casa_org: org_b) }
  let(:volunteer_b) { build_stubbed(:volunteer, casa_org: org_b) }

  permissions :edit?, :update?, :update_password? do
    it "allows casa_admins" do
      is_expected.to permit(casa_admin)
    end

    it "allows supervisor" do
      is_expected.to permit(supervisor)
    end

    it "allows volunteer" do
      is_expected.to permit(volunteer)
    end
  end

  permissions :update_user_setting? do
    context "when user is an admin" do
      it "allows update settings of all roles" do
        is_expected.to permit(casa_admin)
      end
    end

    context "when user is a supervisor" do
      it "allows supervisors to update another volunteer settings" do
        is_expected.to permit(supervisor, volunteer)
      end

      it "does not allow supervisor to update a volunteer in a different casa org" do
        is_expected.not_to permit(supervisor, volunteer_b)
      end

      it "allows supervisors to update their own settings" do
        is_expected.to permit(supervisor, supervisor)
      end

      it "does not allow supervisor to update another supervisor settings" do
        another_supervisor = build_stubbed(:supervisor)
        is_expected.not_to permit(supervisor, another_supervisor)
      end
    end
  end

  permissions :add_language? do
    context "when user is a volunteer" do
      it "allows volunteer to add a language to themselves" do
        is_expected.to permit(volunteer, volunteer)
      end
      it "does not allow another volunteer to add a language to another volunteer" do
        another_volunteer = build_stubbed(:volunteer)
        is_expected.not_to permit(volunteer, another_volunteer)
      end
    end
    context "when user is a supervisor" do
      it "allows supervisors to add a language to a volunteer in their organizations" do
        is_expected.to permit(supervisor_b, volunteer_b)
      end
      it "does not allow a supervisor to add a language to a volunteer in a different organization" do
        is_expected.not_to permit(supervisor, volunteer_b)
      end
    end
    context "when user is an admin" do
      it "allows admins to add a language to a volunteer in their organizations" do
        is_expected.to permit(casa_admin_b, volunteer_b)
      end
      it "does not allow an admin to add a language to a volunteer in a different organization" do
        is_expected.not_to permit(casa_admin, volunteer_b)
      end
    end
  end
end
