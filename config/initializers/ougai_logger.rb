# Apply the monkey patch for Ougai and embed the tags as a field on output
module ActiveSupport::TaggedLogging::Formatter
  def call(severity, time, progname, data)
    data = {msg: data.to_s} unless data.is_a?(Hash)
    tags = current_tags
    data[:tags] = tags if tags.present?
    _call(severity, time, progname, data)
  end
end
