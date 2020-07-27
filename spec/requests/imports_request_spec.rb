require "rails_helper"

RSpec.describe "/imports", type: :request do
  describe "GET /index" do
    it "renders an unsuccessful response when the user is not an admin" do
      sign_in create(:user, :volunteer)

      get imports_url

      expect(response).to_not be_successful
    end

    it "renders a successful response when the user is an admin" do
      sign_in create(:user, :casa_admin)

      get imports_url

      expect(response).to be_successful
    end
  end
end
