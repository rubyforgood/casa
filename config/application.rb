require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Casa
  class Application < Rails::Application
    config.load_defaults 6.0
    config.assets.compile = false
    config.serve_static_assets = true
    config.skylight.environments << "staging"
    config.action_mailer.preview_path = "#{Rails.root}/lib/mailers/previews"
  end
end
