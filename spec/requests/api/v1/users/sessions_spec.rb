require "swagger_helper"

RSpec.describe "sessions API", type: :request do
  let(:casa_org) { create(:casa_org) }
  let(:volunteer) { create(:volunteer, casa_org: casa_org) }

  path "/api/v1/users/sign_in" do
    post "Signs in a user" do
      tags "Sessions"
      consumes "application/json"
      produces "application/json"
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: {type: :string},
          password: {type: :string}
        },
        required: %w[email password]
      }

      response "201", "user signed in" do
        let(:user) { {email: volunteer.email, password: volunteer.password} }
        schema "$ref" => "#/components/schemas/login_success"
        run_test! do |response|
          parsed_response = JSON.parse(response.body)
          expect(parsed_response["api_token"]).not_to be_nil
          expect(parsed_response["refresh_token"]).not_to be_nil
          expect(response.content_type).to eq("application/json; charset=utf-8")
          expect(response.status).to eq(201)
        end
      end

      response "401", "invalid credentials" do
        let(:user) { {email: "foo", password: "bar"} }
        schema "$ref" => "#/components/schemas/login_failure"
        run_test! do |response|
          expect(response.content_type).to eq("application/json; charset=utf-8")
          expect(response.body).to eq({message: "Incorrect email or password."}.to_json)
          expect(response.status).to eq(401)
        end
      end
    end
  end

  path "/api/v1/users/sign_out" do
    delete "Signs out a user" do
      tags "Sessions"
      produces "application/json"
      parameter name: :authorization, in: :header, type: :string, required: true

      let(:api_token) { create(:api_credential, user: volunteer).return_new_api_token![:api_token] }

      response "200", "user signed out" do
        let(:authorization) { "Bearer #{api_token}" }
        schema "$ref" => "#/components/schemas/sign_out"
        run_test! do |response|
          expect(response.content_type).to eq("application/json; charset=utf-8")
          expect(response.body).to eq({message: "Signed out successfully."}.to_json)
          expect(response.status).to eq(200)
        end
      end

      response "401", "unauthorized" do
        let(:authorization) { "Bearer foo" }
        schema "$ref" => "#/components/schemas/sign_out"
        run_test! do |response|
          expect(response.content_type).to eq("application/json; charset=utf-8")
          expect(response.body).to eq({message: "An error occured when signing out."}.to_json)
          expect(response.status).to eq(401)
        end
      end
    end
  end
end
