require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Casa
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets generators tasks mailers])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.eager_load_paths << Rails.root.join("app/lib/importers")
    config.assets.paths << Rails.root.join("app/assets/webfonts")
    config.active_storage.variant_processor = :mini_magick
    config.active_storage.content_types_to_serve_as_binary.delete("image/svg+xml")

    config.action_mailer.preview_paths << Rails.root.join("lib/mailers/previews")
    config.view_component.preview_paths << "#{Rails.root.join("spec/components/previews")}"
  end
end
