require "rails_helper"

RSpec.describe "Health", type: :request do
  before do
    Casa::Application.load_tasks
    Rake::Task["after_party:store_deploy_time"].invoke
  end

  describe "GET /health" do
    before do
      get "/health"
    end

    it "renders an html file" do
      # delete this test when there are more specific tests about the page
      expect(response.header["Content-Type"]).to include("text/html")
    end
  end

  describe "GET /health.json" do
    before do
      get "/health.json"
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
