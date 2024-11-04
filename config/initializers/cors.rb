# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "*" # make sure to change to domain name of frontend
    # TODO: is this applicable? app?
    resource "/api/v1/*", headers: :any, methods: [:get, :post, :patch, :put, :delete, :options, :head]
  end
end
