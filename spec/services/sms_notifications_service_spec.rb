require "rails_helper"

RSpec.describe SmsNotificationsService do
  describe "#create_short_url" do
    it "returns a short url from a long url" do
      response = SmsNotificationsService.new().create_short_url()
      # verify correct request headers
      expect(a_request(:post, "https://api.short.io/links")
        .with(body: "{\"originalURL\":\"https://wiki.com\",\"domain\":\"lel.com\"}", headers: { "Accept" => "application/json", "Content-Type" => "application/json", "Authorization" => ENV["SHORT_API_KEY"] }))
        .to have_been_made.once
      # verify correct response body and code
      expect(response.code).to match 201
      expect(response.body).to match "{\"shortURL\":\"https://lel.com/xpsmpw\"}"
    end
  end
end
