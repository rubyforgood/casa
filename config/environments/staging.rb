Rails.application.configure do
  config.action_mailer.default_url_options = {host: ENV["DEFAULT_URL_HOST"]} # for devise authentication

  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  config.assets.compile = false
  config.active_storage.service = :local
  config.log_level = :debug
  config.log_tags = [:request_id]

  # email
  config.action_mailer.default_url_options = {host: ENV["DEFAULT_URL_HOST"]} # for devise authentication
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      :address => 'smtp-relay.sendinblue.com',
      :port => 587,
      :user_name => ENV["SENDINBLUE_EMAIL"],
      :password => ENV["SENDINBLUE_PASSWORD"],
      :authentication => 'login',
      :enable_starttls_auto => true
  }

  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  config.active_record.dump_schema_after_migration = false
end
