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
require "pry"
require "email_spec"
require "email_spec/rspec"
require "pundit/rspec"
require "view_component/test_helpers"
require "capybara/rspec"
require "action_text/system_test_helper"
require "webmock/rspec"

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
Rails.root.glob("spec/support/**/*.rb").sort_by(&:to_s).each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

ci_environment = (ENV["GITHUB_ACTIONS"] || ENV["CI"]).present?

RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers
  config.include DatatableHelper, type: :datatable
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include Organizational, type: :helper
  config.include Organizational, type: :view
  config.include PunditHelper, type: :view
  config.include SessionHelper, type: :view
  config.include SessionHelper, type: :request
  config.include ViewComponent::TestHelpers, type: :component
  config.include ViewComponent::SystemTestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component
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

  # RSpec Rails uses metadata to mix in different behaviours to your tests,
  # for example enabling you to call `get` and `post` in request specs. e.g.:
  #
  #     RSpec.describe UsersController, type: :request do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://rspec.info/features/7-0/rspec-rails
  #
  # You can also this infer these behaviours automatically by location, e.g.
  # /spec/models would pull in the same behaviour as `type: :model` but this
  # behaviour is considered legacy and will be removed in a future version.
  #
  # To enable this behaviour uncomment the line below.
  # config.infer_spec_type_from_file_location!
  # Auto detect datatable type specs
  config.define_derived_metadata(file_path: Regexp.new("/spec/datatables/")) do |metadata|
    metadata[:type] = :datatable
  end
  # Aggregate failures by default, except slow/sequence-dependant examples (as in system specs)
  config.define_derived_metadata do |metadata|
    non_aggregate_types = %i[system]
    metadata[:aggregate_failures] = true unless non_aggregate_types.include?(metadata[:type])
  end

  # Filter lines from Rails gems in backtraces.
  # Use `rspec --backtrace` option to see full backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
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

  # NOTE: not applicable currently, left to show how to skip bullet errrors
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
