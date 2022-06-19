module TwilioAPI
  def twilio_success_stub_messages_60_days
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

  def twilio_success_stub
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

  def twilio_activation_success_stub(resource = "")
    WebMock.stub_request(:post, "https://api.twilio.com/2010-04-01/Accounts/articuno34/Messages.json")
      .with(
        headers: {
          "Content-Type" => "application/x-www-form-urlencoded",
          "Authorization" => "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=="
        }
      )
      .to_return(body: "{\"error_code\":null, \"status\":\"sent\", \"body\":\"Execute Order 66 - https://42ni.short.gy/jzTwdF\"}")
  end

  def twilio_activation_error_stub(resource = "")
    WebMock.stub_request(:post, "https://api.twilio.com/2010-04-01/Accounts/articuno31/Messages.json")
      .with(
        headers: {
          "Content-Type" => "application/x-www-form-urlencoded",
          "Authorization" => "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=="
        }
      )
      .to_return(body: "{\"error_code\":\"42\", \"status\":\"failed\", \"body\":\"My tea's gone cold I wonder why\"}")
  end

  def twilio_court_report_due_date_stub(resource = "")
    WebMock.stub_request(:post, "https://api.twilio.com/2010-04-01/Accounts/articuno34/Messages.json")
      .with(
        body: {"Body" => "Your court report is due on 2022-06-26. Generate a court report to complete & submit here: https://42ni.short.gy/jzTwdF", "From" => "+15555555555", "To" => ""},
        headers: {
          "Accept" => "application/json",
          "Accept-Charset" => "utf-8",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==",
          "Content-Type" => "application/x-www-form-urlencoded",
          "User-Agent" => "twilio-ruby/5.67.2 (darwin21 arm64) Ruby/3.1.0"
        }
      )
      .to_return(body: "{\"error_code\":null, \"status\":\"sent\", \"body\":\"Your court report is due on 2022-06-26. Generate a court report to complete & submit here: https://42ni.short.gy/jzTwdF\"}")
  end
end
