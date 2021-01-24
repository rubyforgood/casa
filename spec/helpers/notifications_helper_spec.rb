require "rails_helper"

RSpec.describe NotificationsHelper do
  describe "#notification_row_class" do
    context "notification has been read" do
      it "returns 'bg-light text-muted'" do
        notification = build_stubbed(:notification, read_at: Time.current)
        expect(helper.notification_row_class(notification)).to eq(" bg-light text-muted ")
      end
    end

    context "notification has not been read" do
      it "is blank" do
        notification = build_stubbed(:notification, read_at: nil)
        expect(helper.notification_row_class(notification)).to be_blank
      end
    end
  end

  describe "#notification_icon" do
    context "notification has been read" do
      it "is blank" do
        notification = build_stubbed(:notification, read_at: Time.current)
        expect(helper.notification_icon(notification)).to be_blank
      end
    end

    context "notification has not been read" do
      it "shows the bell icon" do
        notification = build_stubbed(:notification, read_at: nil)
        expect(helper.notification_icon(notification)).to eq("<i class='fas fa-bell'></i>")
      end
    end
  end
end
