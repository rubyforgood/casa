require "rails_helper"

RSpec.describe CasaCasePolicy do
  subject { described_class }

  let(:organization) { create(:casa_org) }

  let(:casa_admin) { create(:casa_admin, casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }
  let(:volunteer) { create(:volunteer, casa_org: organization) }
  let(:supervisor) { create(:supervisor, casa_org: organization) }
  let(:casa_admin) { create(:casa_admin, casa_org: organization) }

  permissions :update_case_number? do
    context "when user is an admin" do
      it "does allow update case number" do
        is_expected.to permit(casa_admin, casa_case)
      end
    end

    context "when user is a volunteer" do
      it "does not allow update case number" do
        is_expected.not_to permit(volunteer, casa_case)
      end
    end
  end

  permissions :update_court_date?, :update_court_report_due_date? do
    context "when user is an admin" do
      it "allow update" do
        is_expected.to permit(casa_admin, casa_case)
      end
    end

    context "when user is a supervisor" do
      it "allow update" do
        is_expected.to permit(supervisor, casa_case)
      end
    end

    context "when user is a volunteer" do
      it "does not allow update" do
        is_expected.not_to permit(volunteer, casa_case)
      end
    end
  end

  permissions :update_birth_month_year_youth? do
    context "when user is an admin" do
      it "allow update" do
        is_expected.to permit(casa_admin, casa_case)
      end
    end

    context "when user is a supervisor" do
      it "does not allow update" do
        is_expected.not_to permit(supervisor, casa_case)
      end
    end

    context "when user is a volunteer" do
      it "does not allow update" do
        is_expected.not_to permit(volunteer, casa_case)
      end
    end
  end

  permissions :assign_volunteers? do
    context "when user is an admin" do
      it "does allow volunteer assignment" do
        is_expected.to permit(casa_admin, casa_case)
      end
    end

    context "when user is a volunteer" do
      it "does not allow volunteer assignment" do
        is_expected.not_to permit(volunteer, casa_case)
      end
    end
  end

  permissions :show? do
    it "allows casa_admins" do
      is_expected.to permit(casa_admin, casa_case)
    end

    context "when volunteer is assigned" do
      it "allows the volunteer" do
        volunteer = create(:volunteer, casa_org: organization)
        casa_case = create(:casa_case, casa_org: organization)
        volunteer.casa_cases << casa_case
        is_expected.to permit(volunteer, casa_case)
      end
    end

    context "when volunteer is not assigned" do
      it "does not allow the volunteer" do
        is_expected.not_to permit(volunteer, casa_case)
      end
    end
  end

  permissions :edit? do
    it "allows casa_admins" do
      is_expected.to permit(casa_admin, casa_case)
    end

    context "when volunteer is assigned" do
      it "allows the volunteer" do
        volunteer = create(:volunteer, casa_org: organization)
        casa_case = create(:casa_case, casa_org: organization)
        volunteer.casa_cases << casa_case
        is_expected.to permit(volunteer, casa_case)
      end
    end

    context "when volunteer is not assigned" do
      it "does not allow the volunteer" do
        is_expected.not_to permit(volunteer, casa_case)
      end
    end
  end

  permissions :update? do
    it "allows casa_admins" do
      is_expected.to permit(casa_admin)
    end

    context "when volunteer is assigned" do
      it "allows the volunteer" do
        volunteer = create(:volunteer, casa_org: organization)
        casa_case = create(:casa_case, casa_org: organization)
        volunteer.casa_cases << casa_case
        is_expected.to permit(volunteer, casa_case)
      end
    end

    it "does not allow volunteers who are unassigned" do
      is_expected.not_to permit(volunteer, casa_case)
    end
  end

  permissions :new?, :create?, :destroy? do
    it "allows casa_admins" do
      is_expected.to permit(casa_admin)
    end

    it "does not allow volunteers" do
      is_expected.not_to permit(volunteer)
    end
  end

  permissions :index? do
    it "allows casa_admins" do
      is_expected.to permit(casa_admin)
    end

    it "allows supervisor" do
      is_expected.to permit(supervisor)
    end

    it "allows supervisor" do
      is_expected.to permit(volunteer)
    end
  end
end
