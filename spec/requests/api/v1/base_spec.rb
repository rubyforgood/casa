require "rails_helper"

RSpec.describe "Base Controller", type: :request do
  before do
    base_controller = Class.new(Api::V1::BaseController) do
      def index
        render json: {message: "Successfully autenticated"}
      end
    end
    stub_const("BaseController", base_controller)
    Rails.application.routes.disable_clear_and_finalize = true
    Rails.application.routes.draw do
      get "/index", to: "base#index"
    end
  end

  after { Rails.application.reload_routes! }

  # test authenticate_user! works
  describe "GET #index" do
    let(:user) { create(:volunteer) }
    it "returns http success when valid credentials" do
      get "/index", headers: {"Authorization" => "Token token=#{user.token}, email=#{user.email}"}
      expect(response).to have_http_status(:success)
      expect(response.body).to eq({message: "Successfully autenticated"}.to_json)
    end
    it "returns http unauthorized if invalid token" do
      get "/index", headers: {"Authorization" => "Token token=, email=#{user.email}"}
      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to eq({message: "Wrong password or email"}.to_json)
    end
  end
end
