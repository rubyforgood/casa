require "rails_helper"

RSpec.describe "notifications/index", type: :view do
  let(:notification_1_hour_ago) { create(:notification, :followup_with_note) }
  let(:notification_1_day_ago) { create(:notification, :followup_with_note) }
  let(:notification_2_days_ago) { create(:notification, :followup_with_note) }
  let(:notification_3_days_ago) { create(:notification, :followup_with_note) }

  let(:patch_note_group_all_users) { create(:patch_note_group, :all_users) }
  let(:patch_note_group_no_volunteers) { create(:patch_note_group, :only_supervisors_and_admins) }
  let(:patch_note_type_a) { create(:patch_note_type, name: "patch_note_type_a") }
  let(:patch_note_type_b) { create(:patch_note_type, name: "patch_note_type_b") }
  let(:patch_note_1) { create(:patch_note, note: "Patch Note 1", patch_note_type: patch_note_type_a) }
  let(:patch_note_2) { create(:patch_note, note: "Patch Note B", patch_note_type: patch_note_type_b) }

  before do
    assign(:notifications, Noticed::Notification.all)
    assign(:patch_notes, PatchNote.all)
    assign(:deploy_time, deploy_time)
  end

  context "when there is a deploy date" do
    let(:deploy_time) { 2.days.ago }

    before do
      Health.instance.update_attribute(:latest_deploy_time, deploy_time)
    end

    context "when there are notifications" do
      before do
        notification_1_hour_ago.update_attribute(:created_at, 1.hour.ago)
        notification_1_day_ago.update_attribute(:created_at, 1.day.ago)
        notification_2_days_ago.update_attribute(:created_at, 2.days.ago)
        notification_3_days_ago.update_attribute(:created_at, 3.days.ago)

        patch_note_1.update_attribute(:patch_note_group, patch_note_group_all_users)
      end

      it "has all notifications created after and including the deploy date above the patch note" do
        render template: "notifications/index"

        notifications_html = Nokogiri::HTML5(rendered).css('.list-group-item')
        patch_note_index = notifications_html.index { |node| node.text.include?("Patch Notes") }

        expect(notifications_html[0].text).to include(notification_1_hour_ago.event.message)
        expect(notifications_html[1].text).to include(notification_1_day_ago.event.message)
        expect(notifications_html[2].text).to include(notification_2_days_ago.event.message)
        expect(patch_note_index).to eq(3)
      end

      it "has all notifications created before the deploy date below the patch note" do
        render template: "notifications/index"

        notifications_html = Nokogiri::HTML5(rendered).css('.list-group-item')
        patch_note_index = notifications_html.index { |node| node.text.include?("Patch Notes") }

        expect(patch_note_index).to eq(3)
        expect(notifications_html[patch_note_index + 1].text).to include(notification_3_days_ago.event.message)
      end
    end

    context "when there are patch notes" do
      before do
        patch_note_1.update_attribute(:patch_note_group, patch_note_group_all_users)
        patch_note_2.update_attribute(:patch_note_group, patch_note_group_no_volunteers)
      end

      it "shows all the patch notes available" do
        render template: "notifications/index"

        expect(rendered).to have_text(patch_note_1.note)
        expect(rendered).to have_text(patch_note_2.note)
      end

      it "shows the patch notes under the correct type" do
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
    let(:deploy_time) { nil }

    before do
      notification_1_hour_ago.update_attribute(:created_at, 1.hour.ago)
      notification_1_day_ago.update_attribute(:created_at, 1.day.ago)
      notification_2_days_ago.update_attribute(:created_at, 2.days.ago)
      notification_3_days_ago.update_attribute(:created_at, 3.days.ago)

      patch_note_1.update_attribute(:patch_note_group, patch_note_group_all_users)
      patch_note_2.update_attribute(:patch_note_group, patch_note_group_no_volunteers)
    end

    it "shows the correct number of notifications" do
      render template: "notifications/index"

      expect(rendered).to have_css(".list-group-item", count: 4)
    end

    it "does not display patch notes" do
      render template: "notifications/index"

      notifications_html = Nokogiri::HTML5(rendered).css('.list-group-item')
      view_patch_notes = notifications_html.select { |node| node.text.include?("Patch Notes") }

      expect(PatchNote.all.size).to eql(2)
      expect(view_patch_notes).to be_empty
    end
  end
end
