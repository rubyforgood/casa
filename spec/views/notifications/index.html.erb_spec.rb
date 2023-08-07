require "rails_helper"

RSpec.describe "notifications/index", type: :view do
  before do
    travel_to Date.new(2021, 1, 1)
  end

  context "when there is a deploy date" do
    let(:notification_created_after_deploy_a) { create(:notification) }
    let(:notification_created_after_deploy_b) { create(:notification) }
    let(:notification_created_at_deploy) { create(:notification) }
    let(:notification_created_before_deploy_a) { create(:notification) }
    let(:notification_created_before_deploy_b) { create(:notification) }

    before do
      Health.instance.update_attribute(:latest_deploy_time, 2.days.ago)
    end

    context "when there are notifications" do
      before do
        # TODO invalid notifications that break the view
        # notification_created_after_deploy_a.update_attribute(:created_at, 1.hour.ago)
        # notification_created_after_deploy_b.update_attribute(:created_at, 1.day.ago)
        # notification_created_at_deploy.update_attribute(:created_at, 2.days.ago)
        # notification_created_before_deploy_a.update_attribute(:created_at, 2.days.ago - 1.hour)
        # notification_created_before_deploy_b.update_attribute(:created_at, 3.days.ago)
      end

      xit "has all notifications created after and including the deploy date above the patch note" do
        # TODO fill in after notification factory is given ability to create a notification with notes
      end

      xit "has all notifications created after and including the deploy date above the patch note" do
        # TODO fill in after notification factory is filled out
      end
    end

    context "when there are patch notes" do
      let(:patch_note_group_all_users) { create(:patch_note_group, :all_users) }
      let(:patch_note_group_no_volunteers) { create(:patch_note_group, :only_supervisors_and_admins) }
      let(:patch_note_type_a) { create(:patch_note_type, name: "patch_note_type_a") }
      let(:patch_note_type_b) { create(:patch_note_type, name: "patch_note_type_b") }
      let(:patch_note_1) { create(:patch_note, note: "Patch Note 1", patch_note_type: patch_note_type_a) }
      let(:patch_note_2) { create(:patch_note, note: "Patch Note B", patch_note_type: patch_note_type_b) }

      before do
        Health.instance.update_attribute(:latest_deploy_time, Date.today)
        assign(:notifications, Notification.all)
        patch_note_1.update_attribute(:patch_note_group, patch_note_group_all_users)
        patch_note_2.update_attribute(:patch_note_group, patch_note_group_no_volunteers)
      end

      it "shows all the patch notes available" do
        assign(:patch_notes, PatchNote.all)
        assign(:deploy_time, Time.now)

        render template: "notifications/index"

        expect(rendered).to have_text(patch_note_1.note)
        expect(rendered).to have_text(patch_note_2.note)
      end

      it "shows the patch notes under the correct type" do
        assign(:patch_notes, PatchNote.all)
        assign(:deploy_time, Time.now)

        render template: "notifications/index"

        queryable_html = Nokogiri.HTML5(rendered)

        patch_note_type_a_header = queryable_html.xpath("//*[text()[contains(.,'#{patch_note_type_a.name}')]]").first
        patch_note_type_b_header = queryable_html.xpath("//*[text()[contains(.,'#{patch_note_type_b.name}')]]").first

        patch_note_a_data = patch_note_type_a_header.parent.css("ul").first
        expect(patch_note_a_data.text).to include(patch_note_1.note)

        patch_note_b_data = patch_note_type_b_header.parent.css("ul").first
        expect(patch_note_b_data.text).to include(patch_note_2.note)
      end
    end
  end

  context "without a deploy date" do
    xit "shows the correct number of notifications" do
      # TODO fill in after notification factory is given ability to create displayable notifications
    end
  end
end
