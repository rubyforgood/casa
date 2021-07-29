# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.1"
gem "rails", "~> 6.1.4"

gem "after_party" # post-deployment tasks
gem "amazing_print" # easier console reading
gem "azure-storage-blob", require: false
gem "devise" # for authentication
gem "devise_invitable"
gem "draper" # adds decorators for cleaner presentation logic
gem "faker" # creates realistic seed data, valuable for staging and demos
gem "jbuilder", "~> 2.11" # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "noticed" # Notifications
gem "paper_trail" # tracking changes
gem "pg", ">= 0.18", "< 2.0" # Use postgresql as the database for Active Record
gem "puma", "~> 5.3" # Use Puma as the app server
gem "pundit" # for authorization management - based on user.role field
gem "rack-attack" # for blocking & throttling abusive requests
gem "skylight" # automated performance testing https://www.skylight.io/
gem "webpacker", "~> 5.4" # Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "image_processing", "~> 1.12" # Set of higher-level helper methods for image processing.
gem "lograge" # log less so heroku papertrail quits rate limiting our logs
gem "filterrific" # filtering and sorting of models

gem "bootsnap", ">= 1.4.2", require: false # Reduces boot times through caching; required in config/boot.rb
gem "bugsnag" # tracking errors in prod
gem "sablon" # Word document templating tool for Case Court Reports
gem "paranoia", "~> 2.2" # For soft-deleting purpose
gem "request_store"

group :development, :test do
  gem "bullet" # Detect and fix N+1 queries
  gem "byebug", platforms: %i[mri mingw x64_mingw] # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "erb_lint", require: false
  gem "factory_bot_rails"
  gem "pry"
  gem "pry-byebug"
  gem "rspec-rails", "~> 5.0.1"
  gem "shoulda-matchers"
  gem "standard", "~> 1.1.7" # linter https://github.com/testdouble/standard
  gem "cypress-on-rails", "~> 1.10"
end

group :development do
  gem "annotate" # for adding db field listings to models as comments
  gem "letter_opener" # Opens emails in new tab for easier testing
  gem "listen", ">= 3.0.5", "< 3.7"
  gem "spring" # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring-commands-rspec"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", ">= 3.3.0" # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
end

group :test do
  gem "brakeman" # security inspection
  gem "capybara", ">= 2.15"
  gem "capybara-screenshot"
  gem "database_cleaner-active_record", "~> 2.0.1"
  gem "rake"
  gem "rails-controller-testing"
  gem "selenium-webdriver", "4.0.0.beta4" # temporarily locking to a beta version until 4.x comes out - to fix docker tests https://github.com/SeleniumHQ/selenium/issues/9001
  gem "simplecov", "~> 0.21.2", require: false # 0.17.1 pinned as a workaround for https://github.com/codeclimate/test-reporter/issues/418
  gem "webdrivers" # easy installation and use of web drivers to run system tests with browsers
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
