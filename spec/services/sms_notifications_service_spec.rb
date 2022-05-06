require "rails_helper"

RSpec.describe SmsNotificationsService do
  describe "#create_short_url" do
    it "returns a successful response with correct request" do
      original_url = "https://wiki.com"
      short_domain = "lel.com"
      response = SmsNotificationsService.new(short_domain, "fdfdsf").create_short_url(original_url)
      # verify correct request headers
      expect(a_request(:post, "https://api.short.io/links")
        .with(body: { originalURL: original_url, domain: short_domain }.to_json, headers: { "Accept" => "application/json", "Content-Type" => "application/json", "Authorization" => "fdfdsf" }))
        .to have_been_made.once
      # verify correct response body and code
      puts response.code
      puts response.body
      expect(response.code).to match 200
      expect(response.body).to match "{\"shortURL\":\"https://lel.com/xpsmpw\"}"
    end

    it "returns a short url" do
      original_url = "https://wiki.com"
      short_domain = "lel.com"
      short_url = SmsNotificationsService.new(short_domain, "fdfdsf").get_short_url()
      expect(short_url).to be_an_instance_of(String)
      expect(short_url).to match "https://lel.com/xpsmpw"
    end
  end
end
