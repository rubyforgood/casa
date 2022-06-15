module ApiBaseUrl
  SHORT_IO = "https://api.short.io/"
end

module RequestHeader
  ACCEPT_JSON = {"Accept" => "application/json"}
  CONTENT_TYPE_JSON = {"Content-Type" => "application/json"}
end

module SMSBodyText
  def self.account_activation_msg(resource, base_url = "hello kitty")
    body = "A CASA #{resource} account was created for you.
      Visit #{base_url + "/users/edit"} to change text messaging settings."
  end
end
