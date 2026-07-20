require "rails_helper"

RSpec.describe "Health", type: :request do
  before do
    Health.instance.update_attribute(:latest_deploy_time, Time.current)
  end

  describe "GET /health" do
    before { get "/health" }

    it "renders a minimal, self-contained ops status page" do
      expect(response).to have_http_status(:ok)
      expect(response.header["Content-Type"]).to include("text/html")
      expect(response.body).to include("CASA is running")
    end

    it "exposes no cross-org activity charts (those moved to the authenticated Metrics/Analytics pages)" do
      expect(response.body).not_to include("Case contacts logged")
      expect(response.body).not_to include("Monthly active users")
    end
  end

  describe "GET /health.json" do
    before { get "/health.json" }

    it "renders a json file" do
      expect(response.header["Content-Type"]).to include("application/json")
    end

    it "has key latest_deploy_time" do
      hash_body = nil # This is here for the linter
      expect { hash_body = JSON.parse(response.body).with_indifferent_access }.not_to raise_exception
      expect(hash_body.keys).to contain_exactly("latest_deploy_time")
    end
  end
end
