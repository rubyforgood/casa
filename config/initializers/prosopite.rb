# frozen_string_literal: true

# Rack middleware for development only — in test, scanning is handled by RSpec hooks
if Rails.env.development? &&
    Rails.configuration.respond_to?(:prosopite_enabled) &&
    Rails.configuration.prosopite_enabled
  require "prosopite/middleware/rack"
  Rails.configuration.middleware.use(Prosopite::Middleware::Rack)
end

# Development configuration — test config lives in spec/support/prosopite.rb
Rails.application.config.after_initialize do
  next unless Rails.env.development?

  Prosopite.enabled = Rails.configuration.respond_to?(:prosopite_enabled) &&
    Rails.configuration.prosopite_enabled

  Prosopite.min_n_queries = Rails.configuration.respond_to?(:prosopite_min_n_queries) ?
                            Rails.configuration.prosopite_min_n_queries : 2

  Prosopite.rails_logger = true
  Prosopite.prosopite_logger = true
end
