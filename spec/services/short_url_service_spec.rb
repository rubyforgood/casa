require "rails_helper"
require "support/webmock_helper"

RSpec.describe ShortUrlService do
  describe "short.io API" do
    before :each do
      stubbed_requests
      WebMock.disable_net_connect!
      @original_url = "https://www.google.com/"
      @short_domain = "42ni.short.gy"
      @notification_object = ShortUrlService.new(@short_domain, "1337")
    end

    it "returns a successful response with correct http request" do
      response = @notification_object.create_short_url(@original_url)
      expect(a_request(:post, "https://api.short.io/links")
        .with(body: {originalURL: @original_url, domain: @short_domain}.to_json, headers: {"Accept" => "application/json", "Content-Type" => "application/json", "Authorization" => "1337"}))
        .to have_been_made.once
      expect(response.code).to match 200
      expect(response.body).to match "{\"shortURL\":\"https://42ni.short.gy/jzTwdF\"}"
    end

    it "returns a short url" do
      @notification_object.create_short_url(@original_url)
      short_url = @notification_object.short_url
      expect(short_url).to be_an_instance_of(String)
      expect(short_url).to match "https://42ni.short.gy/jzTwdF"
    end
  end
end
