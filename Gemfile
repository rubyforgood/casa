# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.0"
gem "rails", "~> 6.0.3"

gem "awesome_print" # easier console reading
gem "bootstrap", "~> 4.5.0" # frontend styling library
gem "devise" # for authentication
gem "devise_invitable"
gem "draper" # adds decorators for cleaner presentation logic
gem "faker" # creates realistic seed data, valuable for staging and demos
gem "font-awesome-rails"
gem "jbuilder", "~> 2.7" # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jquery-datatables-rails", "~> 3.4.0"
gem "jquery-rails" # Add jquery to asset pipeline
gem "paper_trail" # tracking changes
gem "pg", ">= 0.18", "< 2.0" # Use postgresql as the database for Active Record
gem "puma", "~> 4.3" # Use Puma as the app server
gem "pundit" # for authorization management - based on user.role field
gem "sass-rails", ">= 6" # Use SCSS for stylesheets
gem 'sib-api-v3-sdk'
gem "skylight" # automated performance testing https://www.skylight.io/
gem "sprockets-rails" # TODO remove (deprecated) Provides Sprockets implementation for Rails Asset Pipeline.
gem "turbolinks", "~> 5" # Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "webpacker", "~> 5.1" # Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker

gem "bootsnap", ">= 1.4.2", require: false # Reduces boot times through caching; required in config/boot.rb
gem "bugsnag" # tracking errors in prod

group :development, :test do
  gem "bullet" # Detect and fix N+1 queries
  gem "byebug", platforms: %i[mri mingw x64_mingw] # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "factory_bot_rails"
  gem "pry"
  gem "pry-byebug"
  gem "rspec-rails", "~> 4.0.1"
  gem "shoulda-matchers"
  gem "standard" # linter https://github.com/testdouble/standard
end

group :development do
  gem "annotate" # for adding db field listings to models as comments
  gem "letter_opener" # Opens emails in new tab for easier testing
  gem "listen", ">= 3.0.5", "< 3.3"
  gem "mailcatcher"
  gem "spring" # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", ">= 3.3.0" # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
end

group :test do
  gem "brakeman" # security inspection
  gem "capybara", ">= 2.15"
  gem "rake"
  gem "selenium-webdriver"
  gem "simplecov", "~> 0.18.5", require: false # pinned as a workaround for https://github.com/codeclimate/test-reporter/issues/418
  gem "webdrivers" # Easy installation and use of web drivers to run system tests with browsers
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
