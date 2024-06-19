require "rails_helper"
require "support/stubbed_requests/webmock_helper"

RSpec.describe ShortUrlService do
  let!(:original_url) { "https://www.google.com" }
  let!(:notification_object) { ShortUrlService.new }
  let!(:short_io_domain) { Rails.application.credentials[:SHORT_IO_DOMAIN] }

  describe "short.io API" do
    before :each do
      WebMockHelper.short_io_stub
    end

    it "returns a successful response with correct http request" do
      response = notification_object.create_short_url(original_url)
      expect(a_request(:post, "https://api.short.io/links")
        .with(body: {originalURL: original_url, domain: short_io_domain}.to_json, headers: {"Accept" => "application/json", "Content-Type" => "application/json", "Authorization" => "1337"}))
        .to have_been_made.once
      expect(response.code).to match 200
      expect(response.body).to match "{\"shortURL\":\"https://42ni.short.gy/jzTwdF\"}"
    end

    it "returns a short url" do
      notification_object.create_short_url(original_url)
      short_url = notification_object.short_url
      expect(short_url).to be_an_instance_of(String)
      expect(short_url).to match "https://42ni.short.gy/jzTwdF"
    end
  end
end
