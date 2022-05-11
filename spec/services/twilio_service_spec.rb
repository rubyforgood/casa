require "rails_helper"

RSpec.describe TwilioService do
  describe "twilio API" do
    context "SMS messaging" do
      before :each do
        stub_request(:post, "https://api.twilio.com/2010-04-01/Accounts/articuno34/Messages.json").
        with(
          body: { From: "+15555555555", Body: "Execute Order 66 - https://42ni.short.gy/jzTwdF", To: "+12222222222" },
          headers: {
            'Content-Type' => 'application/x-www-form-urlencoded',
            'Authorization' => 'Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=='
          }).
        to_return(body: "{\"error_code\":null, \"status\":\"sent\", \"body\":\"Execute Order 66 - https://42ni.short.gy/jzTwdF\"}")
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
        @acc_sid = "articuno34"
        @api_key = "Aladdin"
        @api_secret = "open sesame"
        @short_url = ShortUrlService.new("42ni.short.gy", "1337")
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
        # WebMock.allow_net_connect!(allow: "https://api.short.io/links")
        @short_url.create_short_url("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
        params = {
          From: "+15555555555",
          Body: "Execute Order 66 - ",
          To: "+12222222222",
          URL: @short_url.get_short_url,
         }

        response = @twilio.send_sms(params)
        expect(response.error_code).to match nil
        expect(response.status).to match "sent"
        expect(response.body).to match "Execute Order 66 - https://42ni.short.gy/jzTwdF"
      end
    end
  end
end
