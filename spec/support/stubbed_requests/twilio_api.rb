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
    court_due_date = Date.current + 7.days
    WebMock.stub_request(:post, "https://api.twilio.com/2010-04-01/Accounts/articuno34/Messages.json")
      .with(
        body: {"Body" => "Your court report is due on #{court_due_date}. Generate a court report to complete & submit here: https://42ni.short.gy/jzTwdF", "From" => "+15555555555", "To" => "+12223334444"},
        headers: {
          "Content-Type" => "application/x-www-form-urlencoded",
          "Authorization" => "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=="
        }
      )
      .to_return(body: "{\"error_code\":null, \"status\":\"sent\", \"body\":\"Your court report is due on #{court_due_date}. Generate a court report to complete & submit here: https://42ni.short.gy/jzTwdF\"}")
  end

  def twilio_no_contact_made_stub(resource = "")
    WebMock.stub_request(:post, "https://api.twilio.com/2010-04-01/Accounts/articuno34/Messages.json")
      .with(
        body: {"Body" => "It's been two weeks since you've tried reaching 'test'. Try again! https://42ni.short.gy/jzTwdF", "From" => "+15555555555", "To" => "+12222222222"},
        headers: {
          "Content-Type" => "application/x-www-form-urlencoded",
          "Authorization" => "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=="
        }
      )
      .to_return(body: "{\"error_code\":null, \"status\":\"sent\", \"body\":\"It's been two weeks since you've tried reaching 'test'. Try again! https://42ni.short.gy/jzTwdF\"}")
  end

  def twilio_password_reset_stub(resource)
    WebMock.stub_request(:post, "https://api.twilio.com/2010-04-01/Accounts/articuno34/Messages.json")
      .with(
        body: {From: "+15555555555", Body: "Hi #{resource.display_name}, click here to reset your password: https://42ni.short.gy/jzTwdF", To: "+12222222222"},
        headers: {
          "Content-Type" => "application/x-www-form-urlencoded",
          "Authorization" => "Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=="
        }
      )
      .to_return(body: "{\"error_code\":null, \"status\":\"sent\", \"body\":\"Execute Order 66 - https://42ni.short.gy/jzTwdF\"}")
  end
end
