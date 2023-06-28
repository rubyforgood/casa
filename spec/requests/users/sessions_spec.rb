require "rails_helper"

RSpec.describe "Users::SessionsController", type: :request do
  let(:casa_org) { create(:casa_org) }
  let(:volunteer) { create(:volunteer, casa_org: casa_org) }

  describe "POST create" do
    before {
      @params = {
        user: {
          email: volunteer.email,
          password: volunteer.password
        }
      }
    }

    context "when a user signs in" do
      context "when request format is json" do
        after {
          expect(response).not_to have_http_status(:redirect)
          expect(response.content_type).to eq("application/json; charset=utf-8")
        }

        it "respond with jwt in response header" do
          # header "Content-Type", "application/json; charset=utf-8"
          post "/users/sign_in", as: :json, params: @params
          # print request.headers
          expect(response.headers).to have_key "Authorization"
          expect(response.headers["Authorization"]).to be_starts_with("Bearer")
          expect(response.body).to eq "Successfully authenticated"
        end

        it "respond with status code 401 for bad request" do
          post "/users/sign_in", as: :json, params: {user: {email: "suzume@tojimari.jp", password: ""}}
          expect(response.headers).not_to have_key "Authorization"
          expect(response.body).to eq "Something went wrong with API sign in :("
        end
      end
    end

    context "when a user signs out" do
      context "when request format is json" do
        after { expect(response).not_to have_http_status(:redirect) }

        it "adds JWT to denylist" do
          # header "Content-Type", "application/json; charset=utf-8"
          post "/users/sign_in", as: :json, params: @params
          # get JWT from response header
          auth_bearer = response.headers["Authorization"]
          # print auth_bearer
          expect {
            get "/users/sign_out", as: :json, headers: {"Authorization" => auth_bearer}
          }.to change(JwtDenylist, :count).by(1)
        end

        it "responds with status code 200" do
          # header "Content-Type", "application/json; charset=utf-8"
          post "/users/sign_in", as: :json, params: @params
          get "/users/sign_out", as: :json
        end
      end
    end
  end
end
