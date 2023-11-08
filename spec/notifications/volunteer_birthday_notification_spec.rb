require "rails_helper"

RSpec.describe VolunteerBirthdayNotification, type: :model do
  describe "message" do
    let(:volunteer) do
      build(:volunteer, display_name: "Biday Sewn", date_of_birth: Date.new(1968, 2, 8))
    end

    let(:volunteer_notification) { VolunteerBirthdayNotification.with(volunteer: volunteer) }

    it "contains a short ordinal form of the volunteer's date of birth" do
      expect(volunteer_notification.message).to include "February 8th"
    end

    it "contains the volunteer's name" do
      expect(volunteer_notification.message).to include "Biday Sewn"
    end
  end
end
