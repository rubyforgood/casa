# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.3.10"
gem "rails", "~> 7.2"

gem "after_party" # Post-deployment tasks
gem "amazing_print" # Easier console reading
gem "authtrail" # Track Devise login activity
gem "azure-storage-blob", require: false
gem "blueprinter" # JSON serialization
gem "bugsnag" # Error tracking in production
gem "caxlsx", "~> 4.2" # Excel spreadsheets - TODO can we remove this version restriction?
gem "caxlsx_rails", "~> 0.6.4" # Excel spreadsheets - TODO can we remove this version restriction?
gem "cssbundling-rails", "~> 1.4" # CSS compilation
gem "delayed_job_active_record" # Background job processing
gem "devise" # Authentication
gem "devise_invitable" # User invitation system for Devise
gem "draper" # Decorators for cleaner presentation logic
gem "filterrific" # Filtering and sorting of models
gem "flipper" # Feature flag management
gem "flipper-active_record" # Active Record adapter for Flipper
gem "flipper-ui" # Web UI for managing feature flags
gem "friendly_id", "~> 5.5.1" # Allows us to use a slug instead of CASA case IDs in their URLs
gem "groupdate" # Group data by time periods
gem "httparty" # HTTP network requests
gem "image_processing", "~> 1.14" # Image processing helpers
gem "jbuilder" # JSON API builder
gem "jsbundling-rails" # JavaScript bundling
gem "lograge" # Log less so Heroku Papertrail quits rate limiting our logs
gem "net-imap" # Ruby 3.1+ requires explicit inclusion of standard library gems
gem "net-pop" # Ruby 3.1+ requires explicit inclusion of standard library gems
gem "net-smtp", require: false # Ruby 3.1+ requires explicit inclusion of standard library gems
gem "noticed" # Notifications
gem "oj" # Faster JSON parsing
gem "pagy" # Fast and lightweight pagination
gem "paranoia" # Soft-delete support for Active Record models
gem "pdf-forms" # Filling in fund request PDFs with user input
gem "pg" # Use PostgreSQL as the database for Active Record
gem "pghero" # PostgreSQL performance monitoring and query insights
gem "pg_query" # PostgreSQL query parser
gem "pretender" # Allows admins to impersonate users
gem "puma", "~> 7.0" # Use Puma as the app server
gem "pundit" # Authorization management based on user.role field
gem "rack-attack" # Blocking & throttling abusive requests
gem "rack-cors" # Cross-origin resource sharing
gem "request_store" # Per-request global storage for thread-safe data
gem "rexml" # PDF-forms needs this to deploy to Heroku
gem "rswag-api" # Swagger API documentation
gem "rswag-ui" # Swagger UI
gem "sablon" # Word document templating tool for Case Court Reports
gem "scout_apm" # Application performance monitoring
gem "scout_apm_logging", "~> 2.1" # Scout APM logging integration
gem "sprockets-rails" # Asset pipeline for Rails
gem "stimulus-rails" # Stimulus JavaScript framework
gem "strong_migrations" # Catch unsafe database migrations
gem "turbo-rails", "~> 2.0" # Turbo framework for Rails
gem "twilio-ruby" # Twilio helper functions
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby] # Windows does not include zoneinfo files
gem "view_component" # View components for reusability
gem "wicked" # Multi-step form wizard for Rails

group :development, :test do
  gem "brakeman" # Security inspection
  gem "bullet" # Detect and fix N+1 queries
  gem "byebug", platforms: %i[mri mingw x64_mingw] # Debugger console
  gem "dotenv-rails" # Environment variable management
  gem "erb_lint", require: false # ERB linter
  gem "factory_bot_rails" # Test data factories
  gem "faker" # Creates realistic seed data, valuable for staging and demos
  gem "parallel_tests" # Run tests in parallel
  gem "pry" # Enhanced Ruby console
  gem "pry-byebug" # Pry debugger integration
  gem "rspec_junit_formatter" # JUnit XML formatter for RSpec
  gem "rspec-rails" # RSpec testing framework
  gem "rubocop-capybara", require: false # Capybara linting rules
  gem "rubocop-factory_bot", require: false # FactoryBot linting rules
  gem "rubocop-performance", require: false # Performance linting rules
  gem "rubocop-rspec", require: false # RSpec linting rules
  gem "rubocop-rspec_rails", require: false # RSpec Rails linting rules
  gem "rswag-specs" # Swagger spec generation
  gem "shoulda-matchers" # RSpec matchers for common Rails functionality
  gem "standard", require: false # Ruby style guide
  gem "standard-rails", require: false # Rails-specific style guide
end

group :development do
  gem "annotate" # Adds database field listings to models as comments
  gem "bundler-audit" # Checks for security issues in gems
  gem "letter_opener" # Opens emails in new tab for easier testing
  gem "simplecov-mcp" # SimpleCov MCP integration
  gem "spring" # Speeds up development by keeping your application running in the background
  gem "spring-commands-rspec" # Spring integration for RSpec
  gem "traceroute" # Finds unused routes
  gem "web-console", "~> 4.0" # Interactive console on exception pages
end

group :test do
  gem "capybara" # Integration testing framework
  gem "capybara-screenshot" # Automatic screenshot on test failure
  gem "database_cleaner-active_record" # Database cleaning strategies for tests
  gem "docx" # For testing Word document generation
  gem "email_spec" # Email testing helpers
  gem "rails-controller-testing" # Controller testing helpers
  gem "rspec-retry" # Retries flaky tests
  gem "selenium-webdriver" # Browser automation for system tests
  gem "simplecov", require: false # Code coverage analysis
  gem "webmock" # HTTP request stubber
end
