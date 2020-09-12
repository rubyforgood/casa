require "rails_helper"

RSpec.describe "/all_casa_admins", type: :request do
  describe "GET /edit" do
    context "with a all_casa_admin signed in" do
      it "renders a successful response" do
        sign_in create(:all_casa_admin)

        get edit_all_casa_admins_path

        expect(response).to be_successful
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
        it "updates the all_casa_admin" do
        admin = create(:all_casa_admin)
        sign_in admin

        patch all_casa_admins_path, params: {all_casa_admin: {email: "newemail@example.com"}}

        expect(admin.email).to eq "newemail@example.com"
        expect(response).to have_http_status(:redirect)
      end
    end
    context "with invalid parameters" do
        it "does not update the all_casa_admin" do
        admin = create(:all_casa_admin)
        sign_in admin
        other_admin = create(:all_casa_admin)
        patch all_casa_admins_path, params: {all_casa_admin: {email: other_admin.email}}

        expect(admin.email).to_not eq "newemail@example.com"
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
