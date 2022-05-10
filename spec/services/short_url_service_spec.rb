require "rails_helper"

RSpec.describe ShortUrlService do
  describe "short.io API" do
    before :each do
      @original_url = "https://wiki.com"
      @short_domain = "cw-archives.com"
      @notification_object = ShortUrlService.new(@short_domain, "fdfdsf")
    end

    it "returns a successful response with correct http request" do
      response = @notification_object.create_short_url(@original_url)
      # verify correct request headers
      expect(a_request(:post, "https://api.short.io/links")
        .with(body: { originalURL: @original_url, domain: @short_domain }.to_json, headers: { "Accept" => "application/json", "Content-Type" => "application/json", "Authorization" => "fdfdsf" }))
        .to have_been_made.once
      # verify correct response body and code
      expect(response.code).to match 200
      expect(response.body).to match "{\"shortURL\":\"https://cw-archives.com/fives\"}"
    end

    it "returns a short url" do
      @notification_object.create_short_url(@original_url)
      short_url = @notification_object.get_short_url()
      expect(short_url).to be_an_instance_of(String)
      expect(short_url).to match "https://cw-archives.com/fives"
    end
  end
end
