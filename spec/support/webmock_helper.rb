module StubbedRequests
  def self.allowed_sites(blacklist)
    lambda { |uri|
      blacklist.none? { |site| uri.host.include?(site) }
    }
  end

  module TwilioAPI
    def self.twilio_success_stub_messages_60_days
      WebMock.stub_request(:post, "https://api.twilio.com/2010-04-01/Accounts/articuno34/Messages.json").with(
        headers: {
          "Content-Type" => "application/x-www-form-urlencoded",
          "Authorization" => "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=="
        }
      ).to_return(
        {body: "{\"body\":\"It's been 60 days or more since you've reached out to these members of your youth's network:\"}"},
        {body: "{\"body\":\"• test\"}"},
        {body: "{\"body\":\"If you have made contact with them in the past 60 days, remember to log it: https://42ni.short.gy/jzTwdF\"}"}
      )
    end

    def self.twilio_success_stub
      WebMock.stub_request(:post, "https://api.twilio.com/2010-04-01/Accounts/articuno34/Messages.json")
        .with(
          body: {From: "+15555555555", Body: "Execute Order 66 - https://42ni.short.gy/jzTwdF", To: "+12222222222"},
          headers: {
            "Content-Type" => "application/x-www-form-urlencoded",
            "Authorization" => "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=="
          }
        )
        .to_return(body: "{\"error_code\":null, \"status\":\"sent\", \"body\":\"Execute Order 66 - https://42ni.short.gy/jzTwdF\"}")
    end

    def self.twilio_activation_success_stub(resource)
      WebMock.stub_request(:post, "https://api.twilio.com/2010-04-01/Accounts/articuno34/Messages.json")
        .with(
          headers: {
            "Content-Type" => "application/x-www-form-urlencoded",
            "Authorization" => "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=="
          }
        )
        .to_return(body: "{\"error_code\":null, \"status\":\"sent\", \"body\":\"Execute Order 66 - https://42ni.short.gy/jzTwdF\"}")
    end

    def self.twilio_activation_error_stub(resource)
      WebMock.stub_request(:post, "https://api.twilio.com/2010-04-01/Accounts/articuno31/Messages.json")
        .with(
          headers: {
            "Content-Type" => "application/x-www-form-urlencoded",
            "Authorization" => "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=="
          }
        )
        .to_return(body: "{\"error_code\":\"42\", \"status\":\"failed\", \"body\":\"My tea's gone cold I wonder why\"}")
    end
  end

  module ShortIOAPI
    def self.short_io_stub(base_url = "https://www.google.com")
      WebMock.stub_request(:post, "https://api.short.io/links")
        .with(
          body: {originalURL: base_url, domain: "42ni.short.gy"}.to_json,
          headers: {
            "Accept" => "application/json",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Authorization" => "1337",
            "Content-Type" => "application/json",
            "User-Agent" => "Ruby"
          }
        )
        .to_return(status: 200, body: "{\"shortURL\":\"https://42ni.short.gy/jzTwdF\"}", headers: {})
    end

    def self.short_io_stub_localhost
      WebMock.stub_request(:post, "https://api.short.io/links")
        .with(
          body: {originalURL: base_url, domain: "42ni.short.gy"}.to_json,
          headers: {
            "Accept" => "application/json",
            "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
            "Authorization" => "1337",
            "Content-Type" => "application/json",
            "User-Agent" => "Ruby"
          }
        )
        .to_return(status: 200, body: "{\"shortURL\":\"https://42ni.short.gy/jzTwdF\"}", headers: {})
    end
  end
end
