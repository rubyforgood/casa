require "rails_helper"

RSpec.describe ApiBaseHelper, type: :helper do
  describe "SHORT_IO" do
    it "is the short.io API base URL" do
      expect(ApiBaseHelper::SHORT_IO).to eq("https://api.short.io/")
    end
  end
end
