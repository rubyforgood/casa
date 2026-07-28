require "rails_helper"

RSpec.describe FollowupNotifier, type: :model do
  let(:created_by) { create(:user, display_name: "Ada Lovelace") }

  describe "title" do
    it "returns 'New followup'" do
      followup = create(:followup, :without_note)

      notifier = FollowupNotifier.with(followup: followup, created_by: created_by)

      expect(notifier.title).to eq "New followup"
    end
  end

  describe "url" do
    it "returns the edit path for the followup's case contact" do
      followup = create(:followup, :without_note)

      notifier = FollowupNotifier.with(followup: followup, created_by: created_by)

      expect(notifier.url).to eq "/case_contacts/#{followup.case_contact_id}/edit"
    end
  end

  describe "message" do
    context "when the followup has a note" do
      it "joins the message with newlines and includes the note" do
        followup = create(:followup, :with_note, note: "Needs signature")

        notifier = FollowupNotifier.with(followup: followup, created_by: created_by)

        expect(notifier.message).to eq(
          "Ada Lovelace has flagged a Case Contact that needs follow up.\n" \
          "Note: Needs signature\n" \
          "Click to see more."
        )
      end
    end

    context "when the followup has no note" do
      it "joins the message with spaces and omits the note" do
        followup = create(:followup, :without_note)

        notifier = FollowupNotifier.with(followup: followup, created_by: created_by)

        expect(notifier.message).to eq(
          "Ada Lovelace has flagged a Case Contact that needs follow up. Click to see more."
        )
      end
    end
  end
end
