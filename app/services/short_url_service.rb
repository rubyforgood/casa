require "json"

class ShortUrlService
  attr_reader :short_url

  include ApiBaseHelper
  include RequestHeaderHelper
  include HTTParty
  base_uri SHORT_IO
  headers ACCEPT_JSON
  headers CONTENT_TYPE_JSON

  def initialize
    validate_credentials
    @short_domain = Rails.application.credentials[:SHORT_IO_DOMAIN]
    @short_api_key = Rails.application.credentials[:SHORT_IO_API_KEY]
    @short_url = nil
  end

  # return response containing body, headers ...ect in a hash
  # currently, only need short url from body
  # refer to docs: https://developers.short.io/docs/cre
  def create_short_url(original_url = nil)
    params = {body: {originalURL: original_url, domain: @short_domain}.to_json, headers: {"Authorization" => @short_api_key}}
    response = self.class.post("/links", params)
    @short_url = JSON.parse(response.body)["shortURL"]
    response
  end

  private

  def validate_credentials
    variables = [Rails.application.credentials[:SHORT_IO_DOMAIN], Rails.application.credentials[:SHORT_IO_API_KEY]]
    variables.each do |var|
      if var.blank?
        Rails.logger.error "#{var} environment variable missing for Short IO serivce"
      end
    end
  end
end
