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

  describe "GET #case_contacts_creation_times_in_last_week" do
    it "returns timestamps of case contacts created in the last week" do
      case_contact1 = create(:case_contact, created_at: 1.week.ago)
      case_contact2 = create(:case_contact, created_at: 2.weeks.ago)
      get case_contacts_creation_times_in_last_week_health_index_path
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("application/json")
      timestamps = JSON.parse(response.body)["timestamps"]
      expect(timestamps).to include(case_contact1.created_at.to_i)
      expect(timestamps).not_to include(case_contact2.created_at.iso8601(3))
    end
  end
end
