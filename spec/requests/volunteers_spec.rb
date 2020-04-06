require 'rails_helper'

RSpec.describe "/volunteers", type: :request do
  let(:admin) {
    create(:user, :casa_admin)
  }
  let(:volunteer) {
    create(:user, :volunteer)
  }

  describe "GET /index" do
    it "renders a successful response" do
      sign_in volunteer

      get "/"

      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'render a successful response' do
      sign_in admin

      get edit_volunteer_url(volunteer)

      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    it 'creates a new user' do
      expected_email = "volunteer1@example.com"
      sign_in admin

      post volunteers_url, params: {user: {email: expected_email, casa_org_id: admin.casa_org_id}}

      expect(User.last.email).to eq(expected_email)

      expect(response).to redirect_to root_path
    end
  end

end
