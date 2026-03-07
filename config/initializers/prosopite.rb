# frozen_string_literal: true

# Only enable Rack middleware if Prosopite is configured on
if Rails.configuration.respond_to?(:prosopite_enabled) && Rails.configuration.prosopite_enabled
  require "prosopite/middleware/rack"
  Rails.configuration.middleware.use(Prosopite::Middleware::Rack)
end

Rails.application.config.after_initialize do
  # Core settings
  Prosopite.enabled = Rails.configuration.respond_to?(:prosopite_enabled) &&
                      Rails.configuration.prosopite_enabled

  # Minimum repeated queries to trigger detection (default: 2)
  Prosopite.min_n_queries = Rails.configuration.respond_to?(:prosopite_min_n_queries) ?
                            Rails.configuration.prosopite_min_n_queries : 2

  # Logging options
  Prosopite.rails_logger = true                    # Log to Rails.logger
  Prosopite.prosopite_logger = Rails.env.development?  # Log to log/prosopite.log
end
