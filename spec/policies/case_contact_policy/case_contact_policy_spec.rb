require "rails_helper"

RSpec.describe CaseContactPolicy do
  subject { described_class }

  let(:casa_admin) { create(:casa_admin) }
  let(:case_contact) { create(:case_contact) }
  let(:volunteer) { create(:volunteer) }
  let(:supervisor) { create(:supervisor) }

  permissions :show? do
    it "allows casa_admins" do
      is_expected.to permit(casa_admin, case_contact)
    end

    context "when volunteer is the creator" do
      let(:case_contact) { create(:case_contact, creator: volunteer) }

      it "allows the volunteer" do
        is_expected.to permit(volunteer, case_contact)
      end
    end

    context "when volunteer is not the creator" do
      it "does not allow the volunteer" do
        is_expected.not_to permit(volunteer, case_contact)
      end
    end
  end

  permissions :edit? do
    it "allows casa_admins" do
      is_expected.to permit(casa_admin, case_contact)
    end

    context "when supervisor" do
      let(:case_contact) { create(:case_contact, creator: supervisor) }

      it "allows if is creator" do
        is_expected.to permit(supervisor, case_contact)
      end

      it "does not allow if is not the creator" do
        is_expected.to_not permit(supervisor, create(:case_contact, creator: create(:supervisor)))
      end

      it "allows if is supervisor of the creator" do
        is_expected.to permit(supervisor, create(:case_contact, creator: create(:volunteer, supervisor: supervisor)))
      end

      it "does not allow if is not supervisor of the creator" do
        is_expected.to_not permit(create(:supervisor),
          create(:case_contact, creator: create(:volunteer, supervisor: create(:supervisor))))
      end
    end

    context "when volunteer is assigned" do
      it "allows the volunteer" do
        case_contact = create(:case_contact, creator: volunteer)

        is_expected.to permit(volunteer, case_contact)
      end
    end

    context "when volunteer is not the creator" do
      it "does not allow the volunteer" do
        is_expected.not_to permit(volunteer, case_contact)
      end
    end
  end

  permissions :new? do
    it "allows casa_admins" do
      is_expected.to permit(casa_admin)
    end

    it "does allow volunteers" do
      is_expected.to permit(volunteer, CaseContact.new)
    end
  end

  permissions :update? do
    it "allows casa_admins" do
      is_expected.to permit(casa_admin, case_contact)
    end

    it "does not allow volunteers" do
      is_expected.not_to permit(volunteer, case_contact)
    end

    context "when supervisor" do
      it "allows if is creator" do
        supervisor = create(:supervisor)
        is_expected.to permit(supervisor, create(:case_contact, creator: supervisor))
      end

      it "does not allow if is not the creator" do
        is_expected.to_not permit(create(:supervisor), create(:case_contact, creator: create(:supervisor)))
      end

      it "allows if is supervisor of the creator" do
        supervisor = create(:supervisor)
        is_expected.to permit(supervisor, create(:case_contact, creator: create(:volunteer, supervisor: supervisor)))
      end

      it "does not allow if is not supervisor of the creator" do
        is_expected.to_not permit(create(:supervisor),
          create(:case_contact, creator: create(:volunteer, supervisor: create(:supervisor))))
      end
    end
  end

  permissions :create?, :destroy? do
    it "allows casa_admins" do
      is_expected.to permit(casa_admin, case_contact)
    end

    it "does not allow volunteers" do
      is_expected.not_to permit(volunteer, case_contact)
    end
  end
end
