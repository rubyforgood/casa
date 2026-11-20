# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::SessionsController", type: :request do
  let(:user) { create(:user) }

  describe "GET /users/sign_in" do
    subject(:request) do
      get new_user_session_path

      response
    end

    it { is_expected.to be_successful }
  end

  describe "POST /users/sign_in" do
    subject(:request) do
      post user_session_path, params: params

      response
    end

    context "with valid credentials" do
      let(:params) { {user: {email: user.email, password: "12345678"}} }

      it "successfully authenticates the user" do
        expect(request).to have_http_status(:redirect)
      end
    end

    context "with valid credentials and remember_me parameter" do
      let(:params) { {user: {email: user.email, password: "12345678", remember_me: "1"}} }

      it "successfully authenticates without raising an exception" do
        expect { request }.not_to raise_error
        expect(response).to have_http_status(:redirect)
      end
    end

    context "with invalid credentials and remember_me parameter" do
      let(:params) { {user: {email: user.email, password: "wrong_password", remember_me: "1"}} }

      it "fails normally without raising an exception" do
        expect { request }.not_to raise_error
        expect(response).not_to have_http_status(:redirect)
      end
    end

    context "without parameters" do
      subject(:request) do
        post user_session_path

        response
      end

      it "fails normally without raising an exception" do
        expect { request }.not_to raise_error
        expect(response).not_to have_http_status(:redirect)
      end
    end
  end

  describe "GET /users/sign_out" do
    subject(:request) do
      get destroy_user_session_path

      response
    end

    it { is_expected.to have_http_status(:redirect) }
  end
end
