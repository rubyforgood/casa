Bugsnag.configure do |config|
  config.api_key = ENV["BUGSNAG_API_KEY"]
  config.ignore_classes << ActiveRecord::RecordNotFound
  config.release_stage = ENV["HEROKU_APP_NAME"] || ENV["APP_ENVIRONMENT"]
end
