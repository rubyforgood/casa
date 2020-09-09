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

  describe "has_supervisor?" do
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
end
