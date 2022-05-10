require "rails_helper"

RSpec.describe TwilioService do
  # describe "twilio API" test in the future?
  describe "twilio API" do
    context "SMS messaging" do
      it "can send a SMS successfully" do
        # dut === send_sms
        # input === params (obj)
        # output === response (obj)
        acc_sid = "articuno34"
        api_key = "Aladdin"
        api_secret = "open sesame"
        expected_response = {
          "error_code": nil,
          "status": "sent",
          "body": "The cake is a lie",
        }
        params = {
          From: "+15555555555",
          Body: "The cake is a lie",
          To: "+12222222222",
         }
         twilio = TwilioService.new(api_key, api_secret, acc_sid)
         response = twilio.send_sms(params)
         expect(response.error_code).to match nil
         expect(response.status).to match "sent"
         expect(response.body).to match "The cake is a lie"
      end

      it "can send a SMS with a short url" do
      end
    end
  end
end