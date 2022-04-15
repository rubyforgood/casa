require "rails_helper"

RSpec.describe UserPolicy do
  subject { described_class }

  let(:casa_admin) { build_stubbed(:casa_admin) }
  let(:volunteer) { build_stubbed(:volunteer) }
  let(:supervisor) { build_stubbed(:supervisor) }

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

      it "allows supervisors to update their own settings" do
        is_expected.to permit(supervisor, supervisor)
      end

      it "does not allow supervisor to update another supervisor settings" do
        another_supervisor = build_stubbed(:supervisor)
        is_expected.not_to permit(supervisor, another_supervisor)
      end
    end
  end
end
