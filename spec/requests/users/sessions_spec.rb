require "rails_helper"

RSpec.describe "Users::SessionsController", type: :request do
  let(:casa_org) { create(:casa_org) }
  let(:volunteer) { create(:volunteer, casa_org: casa_org)}

  describe "POST create" do
    #before { @request.env["devise.mapping"] = Devise.mappings[:user] }

    context "when a user signs in" do
      context "when request format is json" do
        it "respond with jwt in response header" do
          params = {
            "user": {
              "email": volunteer.email,
              "password": volunteer.password
            }
          }
          #header "Content-Type", "application/json; charset=utf-8"
          post "/users/sign_in", as: :json, params: params
          #print request.headers
          expect(response.content_type).to eq("application/json; charset=utf-8")
          expect(response.headers).to have_key "Authorization"
          expect(response.headers['Authorization']).to be_starts_with('Bearer')
          expect(response.body).to eq "Successfully authenticated"
          expect(response).not_to have_http_status(:redirect)
        end

        it "respond with status code 401 for bad request" do
          params = {
            "user": {
              "email": "",
              "password": ""
            }
          }
          post "/users/sign_in", as: :json, params: params
          expect(response.content_type).to eq("application/json; charset=utf-8")
          expect(response.headers).not_to have_key "Authorization"
          expect(response.body).to eq "Something went wrong with API sign in :("
          expect(response).not_to have_http_status(:redirect)
        end
      end
    end
  end
end
