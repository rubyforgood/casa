require "rails_helper"

RSpec.describe "AndroidAppAssociations", type: :request do
  describe "GET /index" do
    it "renders a json file" do
      get "/.well-known/assetlinks.json"

      expect(response.header["Content-Type"]).to include("application/json")
    end
  end
end
