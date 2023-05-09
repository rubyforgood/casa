Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*' # make sure to change to domain name of frontend

    resource '*',
        headers: %w(Authorization),
        methods: :any,
        expose: %w(Authorization)
  end
end
