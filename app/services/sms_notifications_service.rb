class SmsNotificationsService
  include HTTParty
  base_uri "https://api.short.io/"
  headers "Accept" => "application/json"
  headers "Content-Type" => "application/json"
  headers "Authorization" => ENV["SHORT_API_KEY"]

  def initialize
  end

  def create_short_url(original_url = nil)
    return { short: "test" }
  end
end
