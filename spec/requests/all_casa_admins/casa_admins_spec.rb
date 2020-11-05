require "rails_helper"

RSpec.describe "/all_casa_admins/casa_orgs/:casa_org_id/casa_admins" do
  let(:all_casa_admin) { create(:all_casa_admin) }
  let(:casa_org) { create(:casa_org) }

  before { sign_in all_casa_admin }

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new CASA admin for the organization" do
        expect {
          post all_casa_admins_casa_org_casa_admins_path(casa_org), params: {
            casa_admin: {
              email: "admin1@example.com",
              display_name: "Example Admin"
            }
          }
        }.to change(CasaAdmin, :count).by(1)
      end
    end
  end

  describe "PATCH /update" do
    let(:email) { "casa_admin@example.com" }
    let(:casa_admin) {
      CasaAdmin.new(
        email: "admin1@example.com",
        display_name: "Example Admin"
      )
    }
    let(:other_admin) {
      CasaAdmin.new(
        email: "other_admin@example.com",
        display_name: "Other Admin"
      )
    }

    context "when current user is all casa admin or casa org admin" do
      it "should allow current user to successfully update other casa admin's email" do
        casa_admin.update(email: "new_email@example.com")

        expect(casa_admin.email).to eq("new_email@example.com")
      end

      it "should successfully deactivate another casa admin's profile" do
        casa_admin.active = true
        casa_admin.deactivate

        expect(casa_admin.active).to eq(false)
      end

      it "should successfully activate another casa admin's profile" do
        casa_admin.active = false
        casa_admin.activate

        expect(casa_admin.active).to eq(true)
      end
    end

    context "when not logged in" do
      it "should not allow access to edit admin page" do
        sign_out all_casa_admin

        get edit_all_casa_admins_casa_org_casa_admin_path(casa_org, create(:casa_admin))
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when user does not have all casa admin permissions" do
      it "should not allow access to edit admin page" do
        sign_out all_casa_admin
        sign_in other_admin

        get edit_all_casa_admins_casa_org_casa_admin_path(casa_org, create(:casa_admin))

        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
# TODO: test admin creation as an all_casa_admin
