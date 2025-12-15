# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::InvitationsController", type: :request do
  let(:casa_org) { create(:casa_org) }
  let(:volunteer) { create(:volunteer, casa_org: casa_org) }

  describe "GET /users/invitation/accept" do
    context "with valid invitation_token" do
      before do
        volunteer.invite!
      end

      it "sets invitation_token on the resource" do
        get accept_user_invitation_path(invitation_token: volunteer.raw_invitation_token)

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Set my password")
        expect(response.body).to include(volunteer.raw_invitation_token)
      end

      it "renders the edit template" do
        get accept_user_invitation_path(invitation_token: volunteer.raw_invitation_token)

        expect(response).to render_template(:edit)
      end
    end

    context "without invitation_token" do
      it "redirects away" do
        get accept_user_invitation_path

        # Devise may redirect to root or sign_in depending on configuration
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "PUT /users/invitation" do
    let(:valid_password) { "Password123!" }

    context "with valid invitation_token and password" do
      before do
        volunteer.invite!
      end

      let(:params) do
        {
          user: {
            invitation_token: volunteer.raw_invitation_token,
            password: valid_password,
            password_confirmation: valid_password
          }
        }
      end

      it "accepts the invitation" do
        expect {
          put user_invitation_path, params: params
        }.to change { volunteer.reload.invitation_accepted_at }.from(nil)
      end

      it "sets the password" do
        put user_invitation_path, params: params

        volunteer.reload
        expect(volunteer.valid_password?(valid_password)).to be true
      end

      it "signs in the user" do
        put user_invitation_path, params: params

        expect(controller.current_user).to eq(volunteer)
      end

      it "redirects after acceptance" do
        put user_invitation_path, params: params

        expect(response).to redirect_to(authenticated_user_root_path)
      end
    end

    context "with invalid invitation_token" do
      let(:params) do
        {
          user: {
            invitation_token: "invalid_token",
            password: valid_password,
            password_confirmation: valid_password
          }
        }
      end

      it "does not accept the invitation" do
        put user_invitation_path, params: params

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Invitation token is invalid")
      end
    end

    context "with blank invitation_token" do
      let(:params) do
        {
          user: {
            invitation_token: "",
            password: valid_password,
            password_confirmation: valid_password
          }
        }
      end

      it "shows validation error" do
        put user_invitation_path, params: params

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Invitation token")
      end
    end

    context "with mismatched passwords" do
      before do
        volunteer.invite!
      end

      let(:params) do
        {
          user: {
            invitation_token: volunteer.raw_invitation_token,
            password: valid_password,
            password_confirmation: "DifferentPassword123!"
          }
        }
      end

      it "does not accept the invitation" do
        expect {
          put user_invitation_path, params: params
        }.not_to change { volunteer.reload.invitation_accepted_at }
      end

      it "shows validation error" do
        put user_invitation_path, params: params

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Password confirmation")
      end
    end

    context "with password too short" do
      before do
        volunteer.invite!
      end

      let(:params) do
        {
          user: {
            invitation_token: volunteer.raw_invitation_token,
            password: "short",
            password_confirmation: "short"
          }
        }
      end

      it "does not accept the invitation" do
        expect {
          put user_invitation_path, params: params
        }.not_to change { volunteer.reload.invitation_accepted_at }
      end

      it "shows validation error" do
        put user_invitation_path, params: params

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Password is too short")
      end
    end

    context "with expired invitation" do
      before do
        volunteer.invite!
        travel_to 2.years.from_now
      end

      after do
        travel_back
      end

      let(:params) do
        {
          user: {
            invitation_token: volunteer.raw_invitation_token,
            password: valid_password,
            password_confirmation: valid_password
          }
        }
      end

      it "does not accept the invitation" do
        expect {
          put user_invitation_path, params: params
        }.not_to change { volunteer.reload.invitation_accepted_at }
      end

      it "shows validation error" do
        put user_invitation_path, params: params

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Invitation token is invalid")
      end
    end
  end

  describe "parameter sanitization" do
    before do
      volunteer.invite!
    end

    it "permits invitation_token in update" do
      params = {
        user: {
          invitation_token: volunteer.raw_invitation_token,
          password: "Password123!",
          password_confirmation: "Password123!",
          extra_param: "should_not_be_permitted"
        }
      }

      put user_invitation_path, params: params

      # If the invitation_token was properly permitted, the invitation should be accepted
      expect(volunteer.reload.invitation_accepted_at).to be_present
    end
  end
end
