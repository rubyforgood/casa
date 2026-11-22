# frozen_string_literal: true

require "rails_helper"

RSpec.describe "AllCasaAdmin::SessionsController", type: :request do
  let(:all_casa_admin) { create(:all_casa_admin) }

  describe "GET /new" do
    subject(:request) do
      get new_all_casa_admin_session_path

      response
    end

    it { is_expected.to be_successful }
  end

  describe "POST /create" do
    subject(:request) do
      post all_casa_admin_session_path, params: params

      response
    end

    context "with valid parameters" do
      let(:params) { {all_casa_admin: {email: all_casa_admin.email, password: all_casa_admin.password}} }

      it { is_expected.to have_http_status(:redirect) }
    end

    context "with valid credentials and remember_me parameter" do
      let(:params) do
        {all_casa_admin: {email: all_casa_admin.email, password: all_casa_admin.password, remember_me: "1"}}
      end

      it "successfully authenticates without raising an exception" do
        expect { request }.not_to raise_error
        expect(response).to have_http_status(:redirect)
      end
    end

    context "with invalid credentials and remember_me parameter" do
      let(:params) do
        {all_casa_admin: {email: all_casa_admin.email, password: "wrong_password", remember_me: "1"}}
      end

      it "fails normally without raising an exception" do
        expect { request }.not_to raise_error
        expect(response).to have_http_status(:ok)
      end
    end

    context "without parameters" do
      subject(:request) do
        post all_casa_admin_session_path

        response
      end

      it { is_expected.to be_successful }
    end
  end

  describe "GET /destroy" do
    subject(:request) do
      get destroy_all_casa_admin_session_path

      response
    end

    it { is_expected.to have_http_status(:redirect) }
  end
end
