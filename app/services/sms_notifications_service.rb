class SmsNotificationsService
  include HTTParty
  base_uri "https://api.short.io/"
  headers "Accept" => "application/json"
  headers "Content-Type" => "application/json"

  def initialize(short_domain = nil, api_key = nil)
    @short_domain = short_domain
    @short_api_key = api_key
    @short_url = nil
  end

  # return response containing body, headers ...ect
  # currently, only need short url from body
  def create_short_url(original_url = nil)
    params = { body: { originalURL: original_url, domain: @short_domain }.to_json, headers: { "Authorization" => @short_api_key } }
    response = self.class.post("/links", params)
    return response
  end

  # to do: short url getter
end
