require "rails_helper"

RSpec.describe Volunteer, type: :model do
  describe "#activate" do
    let(:volunteer) { create(:volunteer, :inactive) }

    it "activates the volunteer" do
      volunteer.activate

      volunteer.reload
      expect(volunteer.active).to eq(true)
    end
  end

  describe "#deactivate" do
    let(:volunteer) { create(:volunteer) }

    it "deactivates the volunteer" do
      volunteer.deactivate

      volunteer.reload
      expect(volunteer.active).to eq(false)
    end

    it "sets all of a volunteer's case assignments to inactive" do
      case_contacts = create_list(:case_assignment, 3, volunteer: volunteer)

      volunteer.deactivate

      case_contacts.each { |c| c.reload }
      expect(case_contacts).to all(satisfy { |c| !c.is_active })
    end
  end

  describe "#display_name" do
    it "allows user to input dangerous values" do
      volunteer = create(:volunteer)
      UserInputHelpers::DANGEROUS_STRINGS.each do |dangerous_string|
        volunteer.update_attribute(:display_name, dangerous_string)
        volunteer.reload

        expect(volunteer.display_name).to eq dangerous_string
      end
    end
  end

  describe "#has_supervisor?" do
    context "when no supervisor_volunteer record" do
      let(:volunteer) { create(:volunteer) }

      it "returns false" do
        expect(volunteer.has_supervisor?).to be false
      end
    end

    context "when active supervisor_volunteer record" do
      let(:sv) { create(:supervisor_volunteer, is_active: true) }
      let(:volunteer) { sv.volunteer }

      it "returns true" do
        expect(volunteer.has_supervisor?).to be true
      end
    end

    context "when inactive supervisor_volunteer record" do
      let(:sv) { create(:supervisor_volunteer, is_active: false) }
      let(:volunteer) { sv.volunteer }

      it "returns false" do
        expect(volunteer.has_supervisor?).to be false
      end
    end
  end

  describe "#made_contact_with_all_cases_in_days?" do
    let(:volunteer) { create(:volunteer) }
    let(:casa_case) { create(:casa_case) }
    let(:create_case_contact) {
      ->(occurred_at, contact_made) {
        create(:case_contact, casa_case: casa_case, creator: volunteer, occurred_at: occurred_at, contact_made: contact_made)
      }
    }
    before do
      create(:case_assignment, casa_case: casa_case, volunteer: volunteer, is_active: true)
    end

    context "when volunteer has made recent contact" do
      it "returns true" do
        create_case_contact.call(Date.current, true)
        expect(volunteer.made_contact_with_all_cases_in_days?).to eq(true)
      end
    end

    context "when volunteer has made recent contact attempt but no contact made" do
      it "returns true" do
        create_case_contact.call(Date.current, false)
        expect(volunteer.made_contact_with_all_cases_in_days?).to eq(false)
      end
    end

    context "when volunteer has not made recent contact" do
      it "returns false" do
        create_case_contact.call(Date.current - 60.days, true)
        expect(volunteer.made_contact_with_all_cases_in_days?).to eq(false)
      end
    end

    context "when volunteer has not made recent contact in just one case" do
      it "returns false" do
        casa_case2 = create(:casa_case)
        create(:case_assignment, casa_case: casa_case2, volunteer: volunteer, is_active: true)
        create(:case_contact, casa_case: casa_case2, creator: volunteer, occurred_at: Date.current - 60.days, contact_made: true)
        create_case_contact.call(Date.current, true)
        expect(volunteer.made_contact_with_all_cases_in_days?).to eq(false)
      end
    end

    context "when volunteer has no case assignments" do
      it "returns true" do
        volunteer2 = create(:volunteer)
        expect(volunteer2.made_contact_with_all_cases_in_days?).to eq(true)
      end
    end
  end

  describe "#supervised_by?" do
    it "is supervised by the currently active supervisor" do
      supervisor = create :supervisor
      volunteer = create :volunteer, supervisor: supervisor

      expect(volunteer).to be_supervised_by(supervisor)
    end

    it "is not supervised by supervisors that have never supervised the volunteer before" do
      supervisor = create :supervisor
      volunteer = create :volunteer

      expect(volunteer).to_not be_supervised_by(supervisor)
    end

    it "is not supervised by supervisor that had the volunteer unassinged" do
      old_supervisor = create :supervisor
      new_supervisor = create :supervisor
      volunteer = create :volunteer, supervisor: old_supervisor

      volunteer.update supervisor: new_supervisor

      expect(volunteer).to_not be_supervised_by(old_supervisor)
      expect(volunteer).to be_supervised_by(new_supervisor)
    end
  end
end
