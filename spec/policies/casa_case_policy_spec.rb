require "rails_helper"

RSpec.describe CasaCasePolicy do
  subject { described_class }

  let(:organization) { build(:casa_org) }
  let(:different_organization) { create(:casa_org) }

  let(:casa_admin) { build(:casa_admin, casa_org: organization) }
  let(:other_org_casa_admin) { build(:casa_admin, casa_org: different_organization) }
  let(:casa_case) { build(:casa_case, casa_org: organization) }
  let(:volunteer) { build(:volunteer, casa_org: organization) }
  let(:other_org_volunteer) { build(:volunteer, casa_org: different_organization) }
  let(:supervisor) { build(:supervisor, casa_org: organization) }
  let(:other_org_supervisor) { build(:supervisor, casa_org: different_organization) }

  permissions :update_case_number? do
    context "when user is an admin" do
      context "from the same organization" do
        it "does allow update" do
          expect(subject).to permit(casa_admin, casa_case)
        end
      end

      context "from a different organization" do
        it "does not allow an update" do
          expect(subject).not_to permit(other_org_casa_admin, casa_case)
        end
      end
    end

    context "when user is a volunteer" do
      it "does not allow update case number" do
        expect(subject).not_to permit(volunteer, casa_case)
      end
    end
  end

  permissions :update_court_date?, :update_court_report_due_date? do
    context "when part of the same organization" do
      context "an admin user" do
        it "can update" do
          expect(subject).to permit(casa_admin, casa_case)
        end
      end

      context "a supervisor user" do
        it "can update" do
          expect(subject).to permit(supervisor, casa_case)
        end
      end

      context "a volunteer user" do
        it "can update" do
          expect(subject).to permit(volunteer, casa_case)
        end
      end
    end

    context "when not part of the same organization" do
      context "an admin user" do
        it "can not update" do
          expect(subject).not_to permit(other_org_casa_admin, casa_case)
        end
      end

      context "a supervisor user" do
        it "can not update" do
          expect(subject).not_to permit(other_org_supervisor, casa_case)
        end
      end

      context "a volunteer user" do
        it "can not update" do
          expect(subject).not_to permit(other_org_volunteer, casa_case)
        end
      end
    end
  end

  permissions :update_hearing_type?, :update_court_orders?, :update_judge? do
    context "when part of the same organization" do
      context "an admin user" do
        it "is allowed to update" do
          expect(subject).to permit(casa_admin, casa_case)
        end
      end

      context "a supervisor user" do
        it "is allowed to update" do
          expect(subject).to permit(supervisor, casa_case)
        end
      end

      context "a volunteer user" do
        it "is allowed to update" do
          expect(subject).to permit(volunteer, casa_case)
        end
      end
    end

    context "when not part of the same organization" do
      context "an admin user" do
        it "is not allowed to update" do
          expect(subject).not_to permit(other_org_casa_admin, casa_case)
        end
      end

      context "a supervisor user" do
        it "is not allowed to update" do
          expect(subject).not_to permit(other_org_supervisor, casa_case)
        end
      end

      context "a volunteer user" do
        it "is not allowed to update" do
          expect(subject).not_to permit(other_org_volunteer, casa_case)
        end
      end
    end
  end

  permissions :update_contact_types? do
    context "when part of the same organization" do
      context "an admin user" do
        it "can update" do
          expect(subject).to permit(casa_admin, casa_case)
        end
      end

      context "a supervisor" do
        it "can update" do
          expect(subject).to permit(supervisor, casa_case)
        end
      end
    end

    context "when not part of the same organization" do
      context "an admin user" do
        it "can not update" do
          expect(subject).not_to permit(other_org_casa_admin, casa_case)
        end
      end

      context "a supervisor" do
        it "can not update" do
          expect(subject).not_to permit(other_org_supervisor, casa_case)
        end
      end
    end

    context "a volunteer" do
      it "does not allow update" do
        expect(subject).not_to permit(volunteer, casa_case)
        expect(subject).not_to permit(other_org_volunteer, casa_case)
      end
    end
  end

  permissions :assign_volunteers? do
    context "when part of the same organization" do
      context "an admin user" do
        it "can do volunteer assignment" do
          expect(subject).to permit(casa_admin, casa_case)
        end
      end
    end

    context "when not part of the same organization" do
      context "an admin user" do
        it "can not do volunteer assignment" do
          expect(subject).not_to permit(other_org_casa_admin, casa_case)
        end
      end
    end

    # TODO: What is the supervisor permission?

    context "when user is a volunteer" do
      it "does not allow volunteer assignment" do
        expect(subject).not_to permit(volunteer, casa_case)
        expect(subject).not_to permit(other_org_volunteer, casa_case)
      end
    end
  end

  permissions "update_emancipation_option?" do
    context "when an admin belongs to the same org as the case" do
      it "allows casa_admins" do
        expect(subject).to permit(casa_admin, casa_case)
      end
    end

    context "when an admin belongs to a different org as the case" do
      it "does not allow admin to update" do
        casa_case = build_stubbed(:casa_case, casa_org: different_organization)
        expect(subject).to permit(other_org_casa_admin, casa_case)
      end
    end

    context "when a supervisor belongs to the same org as the case" do
      it "allows the supervisor" do
        supervisor = build(:supervisor, casa_org: organization)
        casa_case = build_stubbed(:casa_case, casa_org: organization)
        expect(subject).to permit(supervisor, casa_case)
      end
    end

    context "when a supervisor does not belong to the same org as the case" do
      it "does not allow the supervisor" do
        supervisor = build(:supervisor, casa_org: organization)
        casa_case = build_stubbed(:casa_case, casa_org: different_organization)
        expect(subject).not_to permit(supervisor, casa_case)
      end
    end

    context "when volunteer is assigned" do
      it "allows the volunteer" do
        volunteer = create(:volunteer, casa_org: organization)
        casa_case = build(:casa_case, casa_org: organization)
        volunteer.casa_cases << casa_case
        expect(subject).to permit(volunteer, casa_case)
      end
    end

    context "when volunteer is from another organization" do
      it "does not allow the volunteer" do
        volunteer = create(:volunteer, casa_org: different_organization)
        casa_case = build(:casa_case, casa_org: organization)
        expect { volunteer.casa_cases << casa_case }
          .to raise_error(
            ActiveRecord::RecordInvalid,
            /must belong to the same organization/
          )
      end
    end

    context "when volunteer is not assigned" do
      it "does not allow the volunteer" do
        expect(subject).not_to permit(volunteer, casa_case)
        expect(subject).not_to permit(other_org_volunteer, casa_case)
      end
    end
  end

  permissions :show? do
    context "when part of the same organization" do
      context "an admin user" do
        it "allows casa_admins" do
          expect(subject).to permit(casa_admin, casa_case)
        end
      end
    end

    context "when not part of the same organization" do
      context "and admin user" do
        it "does not allow admin to view" do
          expect(subject).not_to permit(other_org_casa_admin, casa_case)
        end
      end
    end

    context "when a supervisor belongs to the same org as the case" do
      it "allows the supervisor" do
        supervisor = create(:supervisor, casa_org: organization)
        casa_case = build_stubbed(:casa_case, casa_org: organization)
        expect(subject).to permit(supervisor, casa_case)
      end
    end

    context "when a supervisor does not belong to the same org as the case" do
      it "does not allow the supervisor" do
        supervisor = build_stubbed(:supervisor, casa_org: organization)
        casa_case = create(:casa_case, casa_org: different_organization)
        expect(subject).not_to permit(supervisor, casa_case)
      end
    end

    context "when volunteer is assigned" do
      it "allows the volunteer" do
        volunteer = create(:volunteer, casa_org: organization)
        casa_case = create(:casa_case, casa_org: organization)
        volunteer.casa_cases << casa_case
        expect(subject).to permit(volunteer, casa_case)
      end
    end

    context "when volunteer is not assigned" do
      it "does not allow the volunteer" do
        expect(subject).not_to permit(volunteer, casa_case)
      end
    end

    context "when volunteer is from another organization" do
      it "does not allow the volunteer" do
        volunteer = create(:volunteer, casa_org: different_organization)
        casa_case = build(:casa_case, casa_org: organization)
        expect { volunteer.casa_cases << casa_case }
          .to raise_error(
            ActiveRecord::RecordInvalid,
            /must belong to the same organization/
          )
      end
    end
  end

  permissions :edit? do
    context "when part of the same organization" do
      it "allows casa_admins" do
        expect(subject).to permit(casa_admin, casa_case)
      end
    end

    context "when not part of the same organization" do
      it "does not allow admin to edit" do
        expect(subject).not_to permit(other_org_casa_admin, casa_case)
      end
    end

    context "when a supervisor belongs to the same org as the case" do
      it "allows the supervisor" do
        supervisor = create(:supervisor, casa_org: organization)
        casa_case = build(:casa_case, casa_org: organization)
        expect(subject).to permit(supervisor, casa_case)
      end
    end

    context "when a supervisor does not belong to the same org as the case" do
      it "does not allow the supervisor" do
        supervisor = build_stubbed(:supervisor, casa_org: organization)
        casa_case = build(:casa_case, casa_org: different_organization)
        expect(subject).not_to permit(supervisor, casa_case)
      end
    end

    context "when volunteer is assigned" do
      it "allows the volunteer" do
        volunteer = create(:volunteer, casa_org: organization)
        casa_case = build(:casa_case, casa_org: organization)
        volunteer.casa_cases << casa_case
        expect(subject).to permit(volunteer, casa_case)
      end
    end

    context "when volunteer is not assigned" do
      it "does not allow the volunteer" do
        expect(subject).not_to permit(volunteer, casa_case)
      end
    end

    context "when volunteer is from another organization" do
      it "does not allow the volunteer" do
        volunteer = create(:volunteer, casa_org: different_organization)
        casa_case = build(:casa_case, casa_org: organization)
        expect { volunteer.casa_cases << casa_case }
          .to raise_error(
            ActiveRecord::RecordInvalid,
            /must belong to the same organization/
          )
      end
    end
  end

  permissions :update? do
    context "when part of the same organization" do
      it "allows casa_admins" do
        expect(subject).to permit(casa_admin, casa_case)
      end
    end

    context "when not part of the same organization" do
      it "does not allow admin to update" do
        expect(subject).not_to permit(other_org_casa_admin, casa_case)
      end
    end

    context "when a supervisor belongs to the same org as the case" do
      it "allows the supervisor" do
        supervisor = create(:supervisor, casa_org: organization)
        casa_case = create(:casa_case, casa_org: organization)
        expect(subject).to permit(supervisor, casa_case)
      end
    end

    context "when a supervisor does not belong to the same org as the case" do
      it "does not allow the supervisor" do
        supervisor = create(:supervisor, casa_org: organization)
        casa_case = build_stubbed(:casa_case, casa_org: different_organization)
        expect(subject).not_to permit(supervisor, casa_case)
      end
    end

    context "when volunteer is assigned" do
      it "allows the volunteer" do
        volunteer = create(:volunteer, casa_org: organization)
        casa_case = build(:casa_case, casa_org: organization)
        volunteer.casa_cases << casa_case
        expect(subject).to permit(volunteer, casa_case)
      end
    end

    it "does not allow volunteers who are unassigned" do
      expect(subject).not_to permit(volunteer, casa_case)
    end

    context "when volunteer is from another organization" do
      it "does not allow the volunteer" do
        volunteer = create(:volunteer, casa_org: different_organization)
        casa_case = build(:casa_case, casa_org: organization)
        expect { volunteer.casa_cases << casa_case }
          .to raise_error(
            ActiveRecord::RecordInvalid,
            /must belong to the same organization/
          )
      end
    end
  end

  permissions :new?, :create?, :destroy? do
    context "when part of the same organizaton" do
      it "allows casa_admins" do
        expect(subject).to permit(casa_admin, casa_case)
      end
    end

    context "when not part of the same organization" do
      it "does not allow admin to create" do
        expect(subject).not_to permit(other_org_casa_admin, casa_case)
      end
    end

    it "does not allow superivsors" do
      expect(subject).not_to permit(supervisor, casa_case)
    end

    it "does not allow volunteers" do
      expect(subject).not_to permit(volunteer, casa_case)
      expect(subject).not_to permit(other_org_volunteer, casa_case)
    end
  end

  permissions :index?, :save_emancipation? do
    # Should :save_emancipation belong with :index?
    # Because we are authorizing without an instance, should we only check a user's
    # role?
    it "allows casa_admins" do
      expect(subject).to permit(casa_admin, CasaCase)
      expect(subject).to permit(other_org_casa_admin, CasaCase)
    end

    it "allows supervisor" do
      expect(subject).to permit(supervisor, CasaCase)
      expect(subject).to permit(other_org_supervisor, CasaCase)
    end

    it "allows volunteer" do
      expect(subject).to permit(volunteer, CasaCase)
      expect(subject).to permit(other_org_volunteer, CasaCase)
    end
  end
end
