require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Casa
  class Application < Rails::Application
    config.load_defaults 6.0
    config.assets.compile = true
    config.serve_static_assets = true
    config.skylight.environments << "staging"
  end
end
