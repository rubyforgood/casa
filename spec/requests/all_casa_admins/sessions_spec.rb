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
    let(:params) { {email: all_casa_admin.email, password: all_casa_admin.password} }
    subject(:request) do
      post all_casa_admin_session_path

      response
    end

    it { is_expected.to be_successful }
  end

  describe "GET /destroy" do
    subject(:request) do
      get destroy_all_casa_admin_session_path

      response
    end

    it { is_expected.to have_http_status(:redirect) }
  end
end
