require "rails_helper"

RSpec.describe Api::V1::BaseController, type: :controller do
  # assert token and options get parsed correctly
  controller do
    def index
      render json: {message: "Successfully autenticated"}
    end

    def authenticated_user!
      super
    end
  end

  # assert authenticate_user! works
  describe "GET #index" do
    let(:user) { create(:volunteer) }
    it "returns http success" do
      request.headers["Authorization"] = "Token token=#{user.token}, email=#{user.email}"
      # print request.headers["Authorization"]
      get :index
      expect(response).to have_http_status(:success)
      expect(response.body).to eq({message: "Successfully autenticated"}.to_json)
    end
    # assert authenticate_user! works with invalid email
    it "returns http unauthorized" do
      request.headers["Authorization"] = "Token token=, email=#{user.email}"
      get :index
      expect(response).to have_http_status(:unauthorized)
      expect(response.body).to eq({message: "Wrong password or email"}.to_json)
    end
  end
end
