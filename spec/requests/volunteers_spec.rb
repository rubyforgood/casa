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
end
