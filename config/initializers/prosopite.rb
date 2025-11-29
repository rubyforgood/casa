# frozen_string_literal: true

if Rails.configuration.x.prosopite_enabled
  require "prosopite/middleware/rack"
  Rails.configuration.middleware.use(Prosopite::Middleware::Rack)
end

Rails.application.config.after_initialize do
  Prosopite.enabled = Rails.configuration.x.prosopite_enabled
  Prosopite.min_n_queries = Rails.configuration.x.prosopite_min_n_queries
  Prosopite.rails_logger = true
end
