require "rails_helper"

RSpec.describe FollowupResolvedNotifier, type: :model do
  let(:created_by) { create(:user, display_name: "Grace Hopper") }
  let(:followup) { create(:followup, :without_note) }

  describe "title" do
    it "returns 'Followup resolved'" do
      notifier = FollowupResolvedNotifier.with(followup: followup, created_by: created_by)

      expect(notifier.title).to eq "Followup resolved"
    end
  end

  describe "message" do
    it "includes the creator's display name" do
      notifier = FollowupResolvedNotifier.with(followup: followup, created_by: created_by)

      # NOTE: unlike FollowupNotifier#build_message (which calls the public
      # `created_by` method), this calls the private `created_by_name` method
      # directly. Both resolve identically here since `created_by` just
      # delegates to `created_by_name`, but it's an inconsistency worth
      # flagging rather than fixing in a test-only PR.
      expect(notifier.message).to eq "Grace Hopper resolved a follow up. Click to see more."
    end
  end

  describe "url" do
    it "includes the case contact edit path and the notification id" do
      notifier = FollowupResolvedNotifier.with(followup: followup, created_by: created_by)
      notifier.save!

      expect(notifier.url).to eq "/case_contacts/#{followup.case_contact_id}/edit?notification_id=#{notifier.id}"
    end

    it "omits notification_id when the notifier has not been persisted" do
      # NOTE: characterizing current behavior - Rails drops nil query params,
      # so an undelivered/unsaved notifier's url has no notification_id at all.
      notifier = FollowupResolvedNotifier.with(followup: followup, created_by: created_by)

      expect(notifier.url).to eq "/case_contacts/#{followup.case_contact_id}/edit"
    end
  end
end
