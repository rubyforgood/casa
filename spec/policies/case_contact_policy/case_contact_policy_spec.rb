require "rails_helper"

RSpec.describe CaseContactPolicy do
  subject { described_class }

  permissions :show? do
    it "allows casa_admins" do
      expect(subject).to permit(create(:casa_admin), create(:case_contact))
    end

    context "when volunteer is the creator" do
      it "allows the volunteer" do
        volunteer = create(:volunteer)
        case_contact = create(:case_contact, creator: volunteer)
        expect(subject).to permit(volunteer, case_contact)
      end
    end

    context "when volunteer is not the creator" do
      it "does not allow the volunteer" do
        expect(subject).not_to permit(create(:volunteer), create(:case_contact))
      end
    end
  end

  permissions :edit? do
    it "allows casa_admins" do
      expect(subject).to permit(create(:casa_admin), create(:case_contact))
    end

    context "when supervisor" do
      it "allows if is creator" do
        supervisor = create(:supervisor)
        expect(subject).to permit(supervisor, create(:case_contact, creator: supervisor))
      end

      it "does not allow if is not the creator" do
        expect(subject).to_not permit(create(:supervisor), create(:case_contact, creator: create(:supervisor)))
      end

      it "allows if is supervisor of the creator" do
        supervisor = create(:supervisor)
        expect(subject).to permit(supervisor, create(:case_contact, creator: create(:volunteer, supervisor: supervisor)))
      end

      it "does not allow if is not supervisor of the creator" do
        expect(subject).to_not permit(create(:supervisor),
          create(:case_contact, creator: create(:volunteer, supervisor: create(:supervisor))))
      end
    end

    context "when volunteer is assigned" do
      it "allows the volunteer" do
        volunteer = create(:volunteer)
        case_contact = create(:case_contact, creator: volunteer)
        expect(subject).to permit(volunteer, case_contact)
      end
    end

    context "when volunteer is not the creator" do
      it "does not allow the volunteer" do
        expect(subject).not_to permit(create(:volunteer), create(:case_contact))
      end
    end
  end

  permissions :new? do
    it "allows casa_admins" do
      expect(subject).to permit(create(:casa_admin))
    end

    it "does allow volunteers" do
      expect(subject).to permit(create(:volunteer), CaseContact.new)
    end
  end

  permissions :update? do
    it "allows casa_admins" do
      expect(subject).to permit(create(:casa_admin), create(:case_contact))
    end

    it "does not allow volunteers" do
      expect(subject).not_to permit(create(:volunteer), create(:case_contact))
    end

    context "when supervisor" do
      it "allows if is creator" do
        supervisor = create(:supervisor)
        expect(subject).to permit(supervisor, create(:case_contact, creator: supervisor))
      end

      it "does not allow if is not the creator" do
        expect(subject).to_not permit(create(:supervisor), create(:case_contact, creator: create(:supervisor)))
      end

      it "allows if is supervisor of the creator" do
        supervisor = create(:supervisor)
        expect(subject).to permit(supervisor, create(:case_contact, creator: create(:volunteer, supervisor: supervisor)))
      end

      it "does not allow if is not supervisor of the creator" do
        expect(subject).to_not permit(create(:supervisor),
          create(:case_contact, creator: create(:volunteer, supervisor: create(:supervisor))))
      end
    end
  end

  permissions :create? do
    it "allows casa_admins" do
      expect(subject).to permit(create(:casa_admin), create(:case_contact))
    end

    it "does not allow volunteers" do
      expect(subject).not_to permit(create(:volunteer), create(:case_contact))
    end
  end

  permissions :destroy? do
    it "allows casa_admins" do
      expect(subject).to permit(create(:casa_admin), create(:case_contact))
    end

    it "does not allow volunteers" do
      expect(subject).not_to permit(create(:volunteer), create(:case_contact))
    end
  end
end
