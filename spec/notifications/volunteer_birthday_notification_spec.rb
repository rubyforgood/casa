require "rails_helper"

RSpec.describe VolunteerBirthdayNotifier, type: :model do
  describe "message" do
    let(:volunteer) do
      create(:volunteer, display_name: "Biday Sewn", date_of_birth: Date.new(1968, 2, 8))
    end

    let(:volunteer_notification) { VolunteerBirthdayNotifier.with(volunteer: volunteer) }

    it "contains a short ordinal form of the volunteer's date of birth" do
      expect(volunteer_notification.message).to include "February 8th"
    end

    it "contains the volunteer's name" do
      expect(volunteer_notification.message).to include "Biday Sewn"
    end
  end
end
