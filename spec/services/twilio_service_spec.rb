require "rails_helper"
require "support/stubbed_requests/webmock_helper"

RSpec.describe TwilioService do
  describe "twilio API" do
    context "SMS messaging" do
      before :all do
        WebMockHelper.twilio_success_stub
        WebMockHelper.short_io_stub
        WebMock.disable_net_connect!
        @short_url = ShortUrlService.new
      end

      let!(:casa_org) do
        create(
          :casa_org,
          twilio_phone_number: "+15555555555",
          twilio_account_sid: "articuno34",
          twilio_api_key_sid: "Aladdin",
          twilio_api_key_secret: "open sesame"
        )
      end

      it "can send a SMS with a short url successfully" do
        @twilio = TwilioService.new(casa_org)
        @short_url.create_short_url("https://www.google.com")
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
