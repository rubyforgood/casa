require "rails_helper"

RSpec.describe "/reports", type: :request do
  describe "GET /index" do
    it "renders a successful response" do
      sign_in create(:user, :volunteer)

      get reports_url

      expect(response).to be_successful
    end
  end
end
