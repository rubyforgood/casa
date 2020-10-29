# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.1"
gem "rails", "~> 6.0.3"

gem "after_party" # post-deployment tasks
gem "amazing_print" # easier console reading
gem "devise" # for authentication
gem "devise_invitable"
gem "draper" # adds decorators for cleaner presentation logic
gem "faker" # creates realistic seed data, valuable for staging and demos
gem "jbuilder", "~> 2.10" # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "paper_trail" # tracking changes
gem "pg", ">= 0.18", "< 2.0" # Use postgresql as the database for Active Record
gem "puma", "~> 5.0" # Use Puma as the app server
gem "pundit" # for authorization management - based on user.role field
gem "skylight" # automated performance testing https://www.skylight.io/
gem "webpacker", "~> 5.2" # Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "image_processing", "~> 1.2" # Set of higher-level helper methods for image processing.

gem "bootsnap", ">= 1.4.2", require: false # Reduces boot times through caching; required in config/boot.rb
gem "bugsnag" # tracking errors in prod
gem "sablon" # Word document templating tool for Case Court Reports

group :development, :test do
  gem "bullet" # Detect and fix N+1 queries
  gem "byebug", platforms: %i[mri mingw x64_mingw] # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "factory_bot_rails"
  gem "pry"
  gem "pry-byebug"
  gem "rspec-rails", "~> 4.0.1"
  gem "shoulda-matchers"
  gem "standard", "~> 0.8.1" # linter https://github.com/testdouble/standard
  gem "cypress-on-rails", "~> 1.0"
end

group :development do
  gem "annotate" # for adding db field listings to models as comments
  gem "erb_lint", require: false
  gem "letter_opener" # Opens emails in new tab for easier testing
  gem "listen", ">= 3.0.5", "< 3.3"
  gem "spring" # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", ">= 3.3.0" # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
end

group :test do
  gem "brakeman" # security inspection
  gem "capybara", ">= 2.15"
  gem "capybara-screenshot"
  gem "rake"
  gem "selenium-webdriver"
  gem "simplecov", "~> 0.17.1", require: false # 0.17.1 pinned as a workaround for https://github.com/codeclimate/test-reporter/issues/418
  gem "webdrivers", require: false # Easy installation and use of web drivers to run system tests with browsers; do not initially require as causes conflict with Docker setup
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
