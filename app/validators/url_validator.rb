class UrlValidator < ActiveModel::EachValidator
  InvalidSchemeError = Class.new StandardError
  MissingHostError = Class.new StandardError

  DEFAULT_SCHEMES = %w[http https].freeze

  def validate_each(record, attribute, value)
    uri = URI.parse(value)
    validate_scheme uri
    validate_host uri
  rescue URI::InvalidURIError
    record.errors.add(attribute, "format is invalid")
  rescue InvalidSchemeError, MissingHostError => e
    record.errors.add(attribute, e.message)
  end

  private

  def validate_scheme(uri)
    accepted_schemes = Array.wrap(options[:scheme] || DEFAULT_SCHEMES)
    return if uri.scheme.in? accepted_schemes

    raise InvalidSchemeError, "scheme invalid - only #{accepted_schemes.join(", ")} allowed"
  end

  def validate_host(uri)
    raise MissingHostError, "host cannot be blank" if uri.host.blank?
  end
end
