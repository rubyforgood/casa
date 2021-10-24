require "rails_helper"

RSpec.describe "Health", type: :request do
  describe "GET /health" do
    before do
      Casa::Application.load_tasks
      Rake::Task["after_party:store_deploy_time"].invoke
      get "/health"
    end

    it "renders a json file" do
      expect(response.header["Content-Type"]).to include("application/json")
    end

    it "has key latest_deploy_time" do
      hash_body = nil # This is here for the linter
      expect { hash_body = JSON.parse(response.body).with_indifferent_access }.not_to raise_exception
      expect(hash_body.keys).to match_array(["latest_deploy_time"])
    end
  end
end
