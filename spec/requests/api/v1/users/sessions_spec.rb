require 'swagger_helper'

RSpec.describe 'sessions API', type: :request do
  path '/api/v1/users/sign_in' do
    post 'Signs in a user' do
      tags 'Sessions'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
          properties: {
            email: { type: :string },
            password: { type: :string }
          },
          required: %w[email password]
      }

      let(:casa_org) { create(:casa_org) }
      let(:volunteer) { create(:volunteer, casa_org: casa_org) }

      response '201', 'user signed in' do
        let(:user) { { email: volunteer.email, password: volunteer.password } }
        schema '$ref' => '#/components/schemas/login_success'
        run_test!
      end

      response '401', 'invalid credentials' do
        let(:user) { { email: 'foo', password: 'bar' } }
        schema '$ref' => '#/components/schemas/login_failure'
        run_test!
      end
    end
  end
end
