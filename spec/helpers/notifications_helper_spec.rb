require "rails_helper"

RSpec.describe NotificationsHelper do
  context "notifications with respect to deploy time" do
    let(:notification_created_after_deploy_a) { create(:notification) }
    let(:notification_created_after_deploy_b) { create(:notification, created_at: 1.day.ago) }
    let(:notification_created_at_deploy) { create(:notification, created_at: 2.days.ago) }
    let(:notification_created_before_deploy_a) { create(:notification, created_at: 2.days.ago - 1.hour) }
    let(:notification_created_before_deploy_b) { create(:notification, created_at: 3.days.ago) }

    before do
      travel_to Time.new(2022, 1, 1, 0, 0, 0)

      notification_created_after_deploy_a.update_attribute(:created_at, 1.hour.ago)
      notification_created_after_deploy_b.update_attribute(:created_at, 1.day.ago)

      Health.instance.update_attribute(:latest_deploy_time, 2.days.ago)
      notification_created_at_deploy.update_attribute(:created_at, 2.days.ago)

      notification_created_before_deploy_a.update_attribute(:created_at, 2.days.ago - 1.hour)
      notification_created_before_deploy_b.update_attribute(:created_at, 3.days.ago)
    end

    describe "#notifications_after_and_including_deploy" do
      let(:notifications_after_and_including_deploy) { helper.notifications_after_and_including_deploy(Notification.all) }
      it "returns all notifications from the given list after and including deploy time" do
        expect(notifications_after_and_including_deploy).to include(notification_created_after_deploy_a)
        expect(notifications_after_and_including_deploy).to include(notification_created_after_deploy_b)
        expect(notifications_after_and_including_deploy).to include(notification_created_at_deploy)
      end

      it "does not contain notifications before the deploy time" do
        expect(notifications_after_and_including_deploy).to_not include(notification_created_before_deploy_a)
        expect(notifications_after_and_including_deploy).to_not include(notification_created_before_deploy_b)
      end
    end

    describe "notifications_before_deploy" do
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
end
