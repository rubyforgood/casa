class UrlValidator < ActiveModel::EachValidator
  DEFAULT_SCHEMES = %w[http https].freeze

  def validate_each(record, attribute, value)
    uri = URI.parse(value)
    accepted_schemes = Array.wrap(options[:scheme] || DEFAULT_SCHEMES)
    record.errors.add(attribute, "scheme invalid - only #{accepted_schemes.join(", ")} allowed") unless uri.scheme.in? accepted_schemes
    record.errors.add(attribute) if uri.host.blank?
  rescue URI::InvalidURIError
    record.errors.add(attribute)
  end
end
