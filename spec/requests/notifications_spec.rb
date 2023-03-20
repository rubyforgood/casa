require "rails_helper"

RSpec.describe "/notifications", type: :request do
  before do
    travel_to Date.new(2021, 1, 1)
  end

  describe "GET /index" do
    context "when there are no patch notes" do
      context "when logged in as an admin" do
        let(:admin) { create(:casa_admin) }

        before do
          sign_in admin
        end

        it "shows the no notification message" do
          get notifications_url

          expect(response.body).to include("You currently don't have any notifications. Notifications are generated when someone requests follow-up on a case contact.")
        end

        context "when there is a deploy date" do
          before do
            Health.instance.update_attribute(:latest_deploy_time, Date.today)
          end

          it "does not show the patch notes section" do
            get notifications_url

            queryable_html = Nokogiri.HTML5(response.body)

            expect(queryable_html.css("h3").text).to_not include("Patch Notes")
          end
        end
      end
    end

    context "when there are patch notes" do
      let(:patch_note_group_all_users) { create(:patch_note_group, :all_users) }
      let(:patch_note_group_no_volunteers) { create(:patch_note_group, :only_supervisors_and_admins) }
      let(:patch_note_type_a) { create(:patch_note_type, name: "patch_note_type_a") }
      let(:patch_note_type_b) { create(:patch_note_type, name: "patch_note_type_b") }
      let(:patch_note_1) { create(:patch_note, note: "*Sy@\\<iiF>(\\\"Q7", patch_note_type: patch_note_type_a) }
      let(:patch_note_2) { create(:patch_note, note: "(W!;Ros>cIWNKX}", patch_note_type: patch_note_type_b) }

      before do
        patch_note_1.update(created_at: Date.new(2020, 12, 31), patch_note_group: patch_note_group_all_users)
        patch_note_2.update(created_at: Date.new(2020, 12, 31), patch_note_group: patch_note_group_no_volunteers)
      end

      context "when logged in as an admin" do
        let(:admin) { create(:casa_admin) }

        before do
          sign_in admin
        end

        context "when there is no deploy date" do
          it "shows the no notification message" do
            get notifications_url

            expect(response.body).to include("You currently don't have any notifications. Notifications are generated when someone requests follow-up on a case contact.")
          end

          it "does not show the patch notes section" do
            get notifications_url

            queryable_html = Nokogiri.HTML5(response.body)

            expect(queryable_html.css("h3").text).to_not include("Patch Notes")
          end
        end

        context "when there is a deploy date" do
          before do
            Health.instance.update_attribute(:latest_deploy_time, Date.new(2021, 1, 1))
          end

          it "does not show the no notification message" do
            get notifications_url

            expect(response.body).to_not include("You currently don't have any notifications. Notifications are generated when someone requests follow-up on a case contact.")
          end

          it "does not show patch notes made after the deploy date" do
            patch_note_1.update_attribute(:created_at, Date.new(2021, 1, 2))
            patch_note_2.update_attribute(:created_at, Date.new(2020, 12, 31))

            get notifications_url

            expect(response.body).to_not include(CGI.escapeHTML(patch_note_1.note))
            expect(response.body).to include(CGI.escapeHTML(patch_note_2.note))
          end
        end
      end

      context "when logged in as volunteer" do
        let(:volunteer) { create(:volunteer) }

        before do
          sign_in volunteer
          Health.instance.update_attribute(:latest_deploy_time, Date.new(2021, 1, 1))
          patch_note_1.update(created_at: Date.new(2020, 12, 31), patch_note_group: patch_note_group_all_users)
          patch_note_2.update(created_at: Date.new(2020, 12, 31), patch_note_group: patch_note_group_no_volunteers)
        end

        it "shows only the patch notes available to their user group" do
          get notifications_url

          expect(response.body).to include(CGI.escapeHTML(patch_note_1.note))
          expect(response.body).to_not include(CGI.escapeHTML(patch_note_2.note))
        end
      end
    end
  end
end
