require "swagger_helper"

RSpec.describe "sessions API", type: :request do
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

      let(:casa_org) { create(:casa_org) }
      let(:volunteer) { create(:volunteer, casa_org: casa_org) }

      response "201", "user signed in" do
        let(:user) { {email: volunteer.email, password: volunteer.password} }
        schema "$ref" => "#/components/schemas/login_success"
        run_test! do |response|
          expect(response.content_type).to eq("application/json; charset=utf-8")
          expect(response.body).to eq(Api::V1::SessionBlueprint.render(volunteer))
          expect(response.status).to eq(201)
        end
      end

      response "401", "invalid credentials" do
        let(:user) { {email: "foo", password: "bar"} }
        schema "$ref" => "#/components/schemas/login_failure"
        run_test! do |response|
          expect(response.content_type).to eq("application/json; charset=utf-8")
          expect(response.body).to eq({message: "Wrong password or email"}.to_json)
          expect(response.status).to eq(401)
        end
      end
    end
  end
end
