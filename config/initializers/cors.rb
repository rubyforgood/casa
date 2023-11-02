Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "*" # make sure to change to domain name of frontend
    resource "/api/v1/*", headers: :any, methods: [:get, :post, :patch, :put, :delete, :options, :head]
  end
end
