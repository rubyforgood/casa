require "rails_helper"

RSpec.describe HealthController, type: :controller do
  describe "#index" do
    let(:expected_response) { {last_deploy_timestamp: File.mtime("app")}.to_json }

    it "returns a json with a timestamp" do
      get :index

      expect(response).to eq(expected_response)
    end
  end
end
