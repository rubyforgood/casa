if ENV["BUGSNAG_API_KEY"].present?
  Bugsnag.configure do |config|
    config.api_key = ENV["BUGSNAG_API_KEY"]
    config.ignore_classes << ActiveRecord::RecordNotFound
    config.release_stage = ENV["HEROKU_APP_NAME"] || ENV["APP_ENVIRONMENT"]

    callback = proc do |event|
      event.set_user(current_user&.id, current_user&.email) if defined?(current_user)
    end

    config.add_on_error(callback)
  end
else
  Bugsnag.configuration.logger = ::Logger.new("/dev/null")
end
