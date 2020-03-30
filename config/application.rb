require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Casa
  class Application < Rails::Application
    config.load_defaults 6.0
    config.factory_bot.definition_file_paths = ["spec/factories"]
  end
end
