require "rails_helper"

RSpec.describe TwilioService do
  describe "twilio API" do
    context "SMS messaging" do
      before :each do
        @acc_sid = "articuno34"
        @api_key = "Aladdin"
        @api_secret = "open sesame"
        @twilio = TwilioService.new(@api_key, @api_secret, @acc_sid)
      end

      it "can send a SMS with a short url successfully" do
        # dut === send_sms()
        # input === params (hash)
        # output === response (twilio API obj)
        expected_response = {
          "error_code": nil,
          "status": "sent",
          "body": "Execute Order 66 - https://42ni.short.gy/jzTwdF",
        }

        # get a real (not stubbed) short url to test
        WebMock.allow_net_connect!(allow: "https://api.short.io/links")
        short_url = ShortUrlService.new("42ni.short.gy", "sk_lrzC9C5wrlnmuKag")
        short_url.create_short_url("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
        params = {
          From: "+15555555555",
          Body: "Execute Order 66 - ",
          To: "+12222222222",
          URL: short_url.get_short_url,
         }

        response = @twilio.send_sms(params)
        expect(response.error_code).to match nil
        expect(response.status).to match "sent"
        expect(response.body).to match "Execute Order 66 - https://42ni.short.gy/jzTwdF"
      end
    end
  end
end
