require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Casa
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.action_mailer.preview_path ||= defined?(Rails.root) ? Rails.root.join("lib", "mailers", "previews") : nil
    config.eager_load_paths << Rails.root.join("app", "lib", "importers")
    config.assets.paths << Rails.root.join("app", "assets", "webfonts")
    config.active_storage.variant_processor = :mini_magick
    config.active_storage.content_types_to_serve_as_binary.delete("image/svg+xml")
    config.serve_static_assets = true
  end
end
