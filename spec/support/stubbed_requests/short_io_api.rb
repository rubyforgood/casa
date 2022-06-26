module ShortIOAPI
  def short_io_stub(base_url = "https://www.google.com")
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

  def short_io_stub_sms
    WebMock.stub_request(:post, "https://api.short.io/links")
      .with(
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

  def short_io_error_stub
    WebMock.stub_request(:post, "https://api.short.io/links")
      .with(
        body: {originalURL: "www.badrequest.com", domain: "42ni.short.gy"}.to_json
      )
      .to_return(status: 401, body: "{\"shortURL\":\"https://42ni.short.gy/jzTwdF\"}", headers: {})
  end

  def short_io_stub_localhost(base_url = "http://localhost:3000/case_contacts/new")
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

  def short_io_court_report_due_date_stub(base_url = "http://localhost:3000/case_court_reports")
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
