require "rails_helper"

RSpec.describe "Users::InvitationsController", type: :request do
  let(:casa_org) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: casa_org) }
  let(:volunteer) { create(:volunteer, casa_org: casa_org) }

  describe "GET /users/invitation/accept" do
    context "with valid invitation token" do
      let(:invitation_token) do
        volunteer.invite!(admin)
        volunteer.raw_invitation_token
      end

      it "renders the invitation acceptance form" do
        get accept_user_invitation_path(invitation_token: invitation_token)

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Set my password")
      end

      it "sets the invitation_token on the resource" do
        get accept_user_invitation_path(invitation_token: invitation_token)

        # Check that the hidden field contains the token
        expect(response.body).to include('name="user[invitation_token]"')
        expect(response.body).to include("value=\"#{invitation_token}\"")
      end
    end

    context "without invitation token" do
      it "redirects to root path" do
        get accept_user_invitation_path

        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PUT /users/invitation" do
    let(:invitation_token) do
      volunteer.invite!(admin)
      volunteer.raw_invitation_token
    end

    context "with valid password" do
      let(:params) do
        {
          user: {
            invitation_token: invitation_token,
            password: "SecurePassword123!",
            password_confirmation: "SecurePassword123!"
          }
        }
      end

      it "accepts the invitation" do
        put user_invitation_path, params: params

        volunteer.reload
        expect(volunteer.invitation_accepted_at).not_to be_nil
      end

      it "redirects to the dashboard" do
        put user_invitation_path, params: params

        expect(response).to redirect_to(root_path)
      end

      it "signs in the user" do
        put user_invitation_path, params: params

        # Follow redirects until we reach the final authenticated page
        follow_redirect! while response.status == 302

        # User should be on an authenticated page
        expect(response).to have_http_status(:success)
      end
    end

    context "with mismatched passwords" do
      let(:params) do
        {
          user: {
            invitation_token: invitation_token,
            password: "SecurePassword123!",
            password_confirmation: "DifferentPassword456!"
          }
        }
      end

      it "does not accept the invitation" do
        put user_invitation_path, params: params

        volunteer.reload
        expect(volunteer.invitation_accepted_at).to be_nil
      end

      it "renders the edit page with errors" do
        put user_invitation_path, params: params

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Password confirmation doesn&#39;t match")
      end
    end

    context "with password too short" do
      let(:params) do
        {
          user: {
            invitation_token: invitation_token,
            password: "short",
            password_confirmation: "short"
          }
        }
      end

      it "does not accept the invitation" do
        put user_invitation_path, params: params

        volunteer.reload
        expect(volunteer.invitation_accepted_at).to be_nil
      end

      it "renders the edit page with errors" do
        put user_invitation_path, params: params

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Password is too short")
      end
    end

    context "with blank password" do
      let(:params) do
        {
          user: {
            invitation_token: invitation_token,
            password: "",
            password_confirmation: ""
          }
        }
      end

      it "does not accept the invitation" do
        put user_invitation_path, params: params

        volunteer.reload
        expect(volunteer.invitation_accepted_at).to be_nil
      end

      it "renders the edit page with errors" do
        put user_invitation_path, params: params

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("can&#39;t be blank")
      end
    end

    context "without invitation token" do
      let(:params) do
        {
          user: {
            password: "SecurePassword123!",
            password_confirmation: "SecurePassword123!"
          }
        }
      end

      it "does not accept the invitation" do
        put user_invitation_path, params: params

        volunteer.reload
        expect(volunteer.invitation_accepted_at).to be_nil
      end

      it "renders the edit page with errors" do
        put user_invitation_path, params: params

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Invitation token can&#39;t be blank")
      end
    end
  end
end
