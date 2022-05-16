require "rails_helper"
require "support/webmock_helper"

RSpec.describe TwilioService do
  describe "twilio API" do
    context "SMS messaging" do
      before :each do
        stubbed_requests
        WebMock.disable_net_connect!
        @acc_sid = "articuno34"
        @api_key = "Aladdin"
        @api_secret = "open sesame"
        @short_url = ShortUrlService.new("42ni.short.gy", "1337")
        @twilio = TwilioService.new(@api_key, @api_secret, @acc_sid)
      end

      it "can send a SMS with a short url successfully" do
        @short_url.create_short_url("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
        params = {
          From: "+15555555555",
          Body: "Execute Order 66 - ",
          To: "+12222222222",
          URL: @short_url.short_url
        }

        # response is a Twilio API obj
        response = @twilio.send_sms(params)
        expect(response.error_code).to match nil
        expect(response.status).to match "sent"
        expect(response.body).to match "Execute Order 66 - https://42ni.short.gy/jzTwdF"
      end
    end
  end
end
