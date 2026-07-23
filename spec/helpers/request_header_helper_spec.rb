require "rails_helper"

RSpec.describe RequestHeaderHelper, type: :helper do
  describe "ACCEPT_JSON" do
    it "is the JSON accept header" do
      expect(RequestHeaderHelper::ACCEPT_JSON).to eq({"Accept" => "application/json"})
    end
  end

  describe "CONTENT_TYPE_JSON" do
    it "is the JSON content type header" do
      expect(RequestHeaderHelper::CONTENT_TYPE_JSON).to eq({"Content-Type" => "application/json"})
    end
  end
end
