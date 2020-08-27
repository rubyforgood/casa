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
end
