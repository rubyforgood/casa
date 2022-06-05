module ApiBaseUrl
  SHORT_IO = "https://api.short.io/"
end

module RequestHeader
  ACCEPT_JSON = {"Accept" => "application/json"}
  CONTENT_TYPE_JSON = {"Content-Type" => "application/json"}
end

module SMSNotifications
  module AccountActivation
    def self.account_activation_msg(resource)
      body = "A CASA #{resource} account was created for you.
      Txt STOP to opt out of text notifications"
    end
  end
end
