require "rails_helper"

RSpec.describe ShortUrlService do
  describe "short.io API" do
    before :each do
      stub_request(:post, "https://api.short.io/links").
      with(
        body: { originalURL: "https://www.youtube.com/watch?v=dQw4w9WgXcQ", domain: "42ni.short.gy" }.to_json,
        headers: {
          'Accept'=>'application/json',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Authorization'=>'1337',
          'Content-Type'=>'application/json',
          'User-Agent'=>'Ruby'
        }).
      to_return(status: 200, body: "{\"shortURL\":\"https://42ni.short.gy/jzTwdF\"}", headers: {})
      WebMock.disable_net_connect!
      @original_url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
      @short_domain = "42ni.short.gy"
      @notification_object = ShortUrlService.new(@short_domain, "1337")
    end

    it "returns a successful response with correct http request" do
      response = @notification_object.create_short_url(@original_url)
      # verify correct request headers
      expect(a_request(:post, "https://api.short.io/links")
        .with(body: { originalURL: @original_url, domain: @short_domain }.to_json, headers: { "Accept" => "application/json", "Content-Type" => "application/json", "Authorization" => "1337" }))
        .to have_been_made.once
      # verify correct response body and code
      expect(response.code).to match 200
      expect(response.body).to match "{\"shortURL\":\"https://42ni.short.gy/jzTwdF\"}"
    end

    it "returns a short url" do
      @notification_object.create_short_url(@original_url)
      short_url = @notification_object.get_short_url()
      expect(short_url).to be_an_instance_of(String)
      expect(short_url).to match "https://42ni.short.gy/jzTwdF"
    end
  end
end
