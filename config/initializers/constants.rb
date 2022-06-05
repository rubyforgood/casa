module ApiBaseUrl
  SHORT_IO = "https://api.short.io/"
end

module RequestHeader
  ACCEPT_JSON = {"Accept" => "application/json"}
  CONTENT_TYPE_JSON = {"Content-Type" => "application/json"}
end

module SMSNotifications
  module AccountActivation
    BODY = "A CASA [volunteer/supervisor/admin] account was created for you. Set your password: [link]
    Txt STOP to opt out of text notifications"
  end
end
