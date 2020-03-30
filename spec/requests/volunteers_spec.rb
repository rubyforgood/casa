require 'rails_helper'

RSpec.describe "/volunteers", type: :request do
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
end
