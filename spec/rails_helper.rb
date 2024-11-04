# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
# Uncomment the line below in case you have `--require rails_helper` in the `.rspec` file
# that will avoid rails generators crashing because migrations haven't been run yet
# return unless Rails.env.test?

require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!
require "webmock/rspec"
require "email_spec"
require "email_spec/rspec"
require "pundit/rspec"
require "view_component/test_helpers"
require "capybara/rspec"
require "action_text/system_test_helper"

ci_environment = (ENV["GITHUB_ACTIONS"] || ENV["CI"]).present?

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Rails.root.glob("spec/support/**/*.rb").sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system

  config.include Organizational, type: :helper
  config.include Organizational, type: :view

  config.include ViewComponent::TestHelpers, type: :component
  config.include ViewComponent::SystemTestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component

  config.include DatatableHelper, type: :datatable

  config.include PunditHelper, type: :view

  config.include TwilioHelper, type: :request
  config.include TwilioHelper, type: :system

  config.include Support::RequestHelpers, type: :request

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [
    Rails.root.join("spec/fixtures")
  ]

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://rspec.info/features/7-0/rspec-rails
  config.infer_spec_type_from_file_location!

  # Auto detect datatable type specs
  config.define_derived_metadata(file_path: Regexp.new("/spec/datatables/")) do |metadata|
    metadata[:type] = :datatable
  end
  config.define_derived_metadata(file_path: Regexp.new("/spec/system//")) do |metadata|
    metadata[:type] = :system # needs to be set for aggregate_failures below (vs inferred)
  end
  # Aggregate failures by default. Not as useful for system specs, they need to fail fast.
  config.define_derived_metadata do |metadata|
    metadata[:aggregate_failures] = true unless metadata[:type] == :system
  end

  config.example_status_persistence_file_path = Rails.root.join("tmp/persistent_examples.txt")

  # Auto detect datatable type specs
  config.define_derived_metadata(file_path: Regexp.new("/spec/datatables/")) do |metadata|
    metadata[:type] = :datatable
  end

  config.example_status_persistence_file_path = "#{Rails.root.join("tmp/persistent_examples.txt")}"

  # Filter backtraces to gems that are not under our control.
  # Can override using `--backtrace` option to rspec to see full backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered; use `--backtrace` option to see full backtraces.
  config.filter_gems_from_backtrace(*%w[
    bootsnap capybara factory_bot puma rack railties shoulda-matchers
    sprockets-rails pundit
  ])

  config.around do |example|
    # If timeout is not set it will run without a timeout
    Timeout.timeout(ENV["TEST_MAX_DURATION"].to_i) do
      example.run
    end
  rescue Timeout::Error
    raise StandardError.new "\"#{example.full_description}\" in #{example.location} timed out."
  end

  # NOTE: not applicable currently, leaving to show how to skip bullet errrors for later
  # config.around :each, :disable_bullet do |example|
  #   Bullet.raise = false
  #   example.run
  #   Bullet.raise = true
  # end

  config.around do |example|
    Capybara.server_port = 7654 + ENV["TEST_ENV_NUMBER"].to_i
    example.run
  end

  config.filter_run_excluding :ci_only unless ci_environment
end

RSpec::Matchers.define_negated_matcher :not_change, :change

Shoulda::Matchers.configure do |shoulda_config|
  shoulda_config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: "selenium_chrome:4444"
)

require "test-prof"

TestProf.configure do |config|
  # the directory to put artifacts (reports) in ('tmp/test_prof' by default)
  config.output_dir = "tmp/test_prof"
  # use unique filenames for reports (by simply appending current timestamp)
  config.timestamps = true
  # color output
  config.color = true
  # where to write logs (defaults)
  config.output = $stdout
  # alternatively, you can specify a custom logger instance
  # config.logger = MyLogger.new
end

if ci_environment
  # profiling tools not used in CI

  require "test_prof/recipes/rspec/sample"

  TestProf::StackProf.configure do |config|
    config.format = "json"
  end
end
