require "rails_helper"

RSpec.describe StaticController, type: :controller do
  describe "#index" do
    before { get :index }

    it "returns a successful response" do
      expect(response).to be_successful
    end
  end
end
