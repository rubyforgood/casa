require "rails_helper"

RSpec.describe "/followups", :disable_bullet, type: :request do
  let(:admin) { create(:casa_admin) }
  let(:volunteer) { create(:volunteer) }
  let(:contact) { create(:case_contact) }

  describe "PATCH /resolve" do
    context "followup exists" do
      let!(:followup) { create(:followup, case_contact: contact) }

      it "marks it as :resolved" do
        sign_in admin
        patch resolve_followup_path(followup)

        expect(followup.reload.resolved?).to be_truthy
      end

      context "notifications" do
        context "volunteer resolves followup, admin is creator" do
          let!(:followup) { create(:followup, creator: admin, case_contact: contact) }
          it "should create a notification for the admin" do
            sign_in volunteer

            patch resolve_followup_path(followup)

            expect(Notification.count).to eq(1)
            expect(admin.notifications.count).to eq(1)
          end
        end

        context "volunteer resolves followup that they created" do
          let!(:followup) { create(:followup, creator: volunteer, case_contact: contact) }
          it "should not create a notification" do
            sign_in volunteer

            patch resolve_followup_path(followup)

            expect(Notification.count).to eq(0)
          end
        end
      end
    end

    context "followup doesn't exists" do
      it "raises ActiveRecord::RecordNotFound" do
        sign_in admin

        expect {
          patch resolve_followup_path(444444)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      context "no followup exists yet" do
        it "creates a followup" do
          sign_in admin

          expect {
            post case_contact_followups_path(contact)
          }.to change(Followup, :count).by(1)
        end
      end

      context "followup exists and is in :requested status" do
        let!(:followup) { create(:followup, case_contact: contact) }

        it "should not create another followup" do
          sign_in admin

          expect {
            post case_contact_followups_path(contact)
          }.not_to change(Followup, :count)
        end
      end
    end

    context "with invalid case_contact" do
      it "raises ActiveRecord::RecordNotFound" do
        sign_in admin

        expect {
          post case_contact_followups_path(444444)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "notifications" do
      context "supervisor/admin creates followup" do
        let(:volunteer_2) { create(:volunteer) }
        let(:unassigned_volunteer) { create(:volunteer) }

        it "should only create a notification for the user that created the case_contact" do
          contact_created_by_volunteer = create(:case_contact, creator: volunteer)
          casa_case = contact_created_by_volunteer.casa_case
          casa_case.assigned_volunteers = [volunteer, volunteer_2]
          sign_in admin

          post case_contact_followups_path(contact_created_by_volunteer)

          expect(volunteer.notifications.count).to eq(1)
          expect(volunteer_2.notifications.count).to eq(0)
          expect(unassigned_volunteer.notifications.count).to eq(0)
        end
      end
    end
  end
end
