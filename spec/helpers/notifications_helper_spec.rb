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
      let(:notifications_after_and_including_deploy) { helper.notifications_after_and_including_deploy(Noticed::Notification.all) }

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

    describe "#notifications_before_deploy" do
      let(:notifications_before_deploy) { helper.notifications_before_deploy(Noticed::Notification.all) }

      it "returns all notifications from the given list before deploy time" do
        expect(notifications_before_deploy).to include(notification_created_before_deploy_a)
        expect(notifications_before_deploy).to include(notification_created_before_deploy_b)
      end

      it "does not contain notifications after and including the deploy time" do
        expect(notifications_before_deploy).to_not include(notification_created_after_deploy_a)
        expect(notifications_before_deploy).to_not include(notification_created_after_deploy_b)
        expect(notifications_before_deploy).to_not include(notification_created_at_deploy)
      end
    end
  end

  describe "#patch_notes_as_hash_keyed_by_type_name" do
    it "returns a hash where the keys are the names of the patch note type and the values are lists of patch note strings belonging to the type" do
      patch_note_type_a = create(:patch_note_type, name: "patch_note_type_a")
      patch_note_type_b = create(:patch_note_type, name: "patch_note_type_b")
      patch_note_1 = create(:patch_note, note: "Patch Note 1", patch_note_type: patch_note_type_a)
      patch_note_2 = create(:patch_note, note: "Patch Note 2", patch_note_type: patch_note_type_b)
      patch_note_3 = create(:patch_note, note: "Patch Note 3", patch_note_type: patch_note_type_b)

      patch_notes_hash = helper.patch_notes_as_hash_keyed_by_type_name(PatchNote.all)

      expect(patch_notes_hash).to have_key(patch_note_type_a.name)
      expect(patch_notes_hash).to have_key(patch_note_type_b.name)
      expect(patch_notes_hash[patch_note_type_a.name]).to contain_exactly(patch_note_1.note)
      expect(patch_notes_hash[patch_note_type_b.name]).to contain_exactly(patch_note_2.note, patch_note_3.note)
    end
  end
end
