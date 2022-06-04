module StubbedRequests
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

  def self.twilio_error_stub
    WebMock.stub_request(:post, "https://api.twilio.com/2010-04-01/Accounts/articuno34/Messages.json")
    .with(
      body: {From: "+15555555555", Body: "My tea's gone cold I wonder why", To: "+12222222222"},
      headers: {
        "Content-Type" => "application/x-www-form-urlencoded",
        "Authorization" => "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=="
      }
    )
    .to_return(body: "{\"error_code\":\"42"\, \"status\":\"failed\", \"body\":\"My tea's gone cold I wonder why\"}")
  end

  def self.short_io_stub
    WebMock.stub_request(:post, "https://api.short.io/links")
    .with(
      body: {originalURL: "https://www.youtube.com/watch?v=dQw4w9WgXcQ", domain: "42ni.short.gy"}.to_json,
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
