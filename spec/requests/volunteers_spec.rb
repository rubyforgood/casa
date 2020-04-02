require 'rails_helper'

RSpec.describe "/volunteers", type: :request do
  let(:volunteer) {
    create(:user, :volunteer)
  }

  before(:each) {
    sign_in volunteer
  }

  describe "GET /index" do
    it "renders a successful response" do
      get "/"

      expect(response).to be_successful
    end
  end
end
