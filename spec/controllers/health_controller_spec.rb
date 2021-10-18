require "rails_helper"

RSpec.describe HealthController, type: :controller do
  describe "#index" do
    let(:admin) { create(:casa_admin) }
    let(:expected_response) { {last_deploy_timestamp: File.mtime("app")}.to_json }

    it "returns a json with a timestamp" do
      sign_in admin

      get :index

      expect(response.body).to eq(expected_response)
    end
  end
end
