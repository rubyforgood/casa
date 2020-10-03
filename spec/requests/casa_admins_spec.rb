require "rails_helper"

RSpec.describe "/casa_admins", type: :request do
  describe "GET /casa_admins/:id/edit" do
    context "logged in as admin user" do
      it "can successfully access a casa admin edit page" do
        sign_in_as_admin

        get edit_casa_admin_path(create(:casa_admin))

        expect(response).to be_successful
      end
    end

    context "logged in as a non-admin user" do
      it "cannot access a casa admin edit page" do
        sign_in_as_volunteer

        get edit_casa_admin_path(create(:casa_admin))

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "unauthenticated request" do
      it "cannot access a casa admin edit page" do
        get edit_casa_admin_path(create(:casa_admin))

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "PUT /casa_admins/:id" do
    context "logged in as admin user" do
      it "can successfully update a casa admin user" do
        sign_in_as_admin
        casa_admin = create(:casa_admin)
        expected_display_name = "Admin 2"
        expected_email = "admin2@casa.com"

        put casa_admin_path(casa_admin), params: {
          casa_admin: {
            email: expected_email,
            display_name: expected_display_name
          }
        }

        casa_admin.reload
        expect(casa_admin.email).to eq expected_email
        expect(casa_admin.display_name).to eq expected_display_name

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Admin was successfully updated."
      end
    end

    context "logged in as a non-admin user" do
      it "cannot update a casa admin user" do
        sign_in_as_volunteer

        put casa_admin_path(create(:casa_admin)), params: {
          casa_admin: {
            email: "admin@casa.com",
            display_name: "The admin"
          }
        }

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "unauthenticated request" do
      it "cannot update a casa admin user" do
        put casa_admin_path(create(:casa_admin)), params: {
          casa_admin: {
            email: "admin@casa.com",
            display_name: "The admin"
          }
        }

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "PATCH /activate" do
    let(:casa_admin) { create(:casa_admin, active: false) }

    it "activates an inactive casa_admin" do
      sign_in_as_admin

      patch activate_casa_admin_path(casa_admin)

      casa_admin.reload
      expect(casa_admin.active).to eq(true)
    end

    it "sends an activation email" do
      sign_in_as_admin

      expect {
        patch activate_casa_admin_path(casa_admin)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe "PATCH /casa_admins/:id/deactivate" do
    let(:casa_admin) { create(:casa_admin, active: false) }

    context "logged in as admin user" do
      it "can successfully deactivate a casa admin user" do
        sign_in_as_admin
        expected_display_name = "Admin 2"
        expected_email = "admin2@casa.com"

        patch deactivate_casa_admin_path(casa_admin)
        casa_admin.reload
        expect(casa_admin.active).to be_falsey

        expect(response).to redirect_to edit_casa_admin_path(casa_admin)
        expect(response.request.flash[:notice]).to eq "Admin was deactivated."
      end

      it "sends a deactivation email" do
        sign_in_as_admin

        expect {
          patch deactivate_casa_admin_path(casa_admin)
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context "logged in as a non-admin user" do
      it "cannot update a casa admin user" do
        sign_in_as_volunteer

        patch deactivate_casa_admin_path(create(:casa_admin))

        expect(response).to redirect_to root_path
        expect(response.request.flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
      end
    end

    context "unauthenticated request" do
      it "cannot update a casa admin user" do
        patch deactivate_casa_admin_path(create(:casa_admin))

        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
