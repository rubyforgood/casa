require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__) # Prevent database truncation in production. Local? Try RAILS_ENV=test
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!
require "pundit/rspec"
require "view_component/test_helpers"
require "capybara/rspec"
require "action_text/system_test_helper"

# Require all support folder files
Dir[Rails.root.join("spec", "support", "**", "*.rb")].sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

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
  config.include TemplateHelper
  config.include Warden::Test::Helpers
  config.include ViewComponent::TestHelpers, type: :component
  config.include ViewComponent::SystemTestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component
  config.include ActionText::SystemTestHelper, type: :system
  config.include TwilioHelper, type: :request
  config.include TwilioHelper, type: :system

  config.after do
    Warden.test_reset!
  end

  Shoulda::Matchers.configure do |shoulda_config|
    shoulda_config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end

  # Changes to fix warning of Rails 7.1 has deprecated the singular fixture_path in favour of an array
  config.fixture_paths = ["#{::Rails.root}/spec/fixtures"]

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  # Auto detect datatable type specs
  config.define_derived_metadata(file_path: Regexp.new("/spec/datatables/")) do |metadata|
    metadata[:type] = :datatable
  end

  config.example_status_persistence_file_path = "#{::Rails.root}/tmp/persistent_examples.txt"

  # Filter backtraces to gems that are not under our control.
  # Can override using `--backtrace` option to rspec to see full backtraces.
  config.filter_rails_from_backtrace!
  config.filter_gems_from_backtrace(*%w[
    bootsnap capybara factory_bot puma rack railties shoulda-matchers
    sprockets-rails pundit
  ])

  config.disable_monkey_patching!

  config.around :each do |example|
    # If timeout is not set it will run without a timeout
    Timeout.timeout(ENV["TEST_MAX_DURATION"].to_i) do
      example.run
    end
  rescue Timeout::Error
    raise StandardError.new "\"#{example.full_description}\" in #{example.location} timed out."
  end

  config.around :each, :disable_bullet do |example|
    Bullet.raise = false
    example.run
    Bullet.raise = true
  end

  def pre_transition_aged_youth_age
    Date.current - CasaCase::TRANSITION_AGE.years
  end

  config.around do |example|
    Capybara.server_port = 7654 + ENV["TEST_ENV_NUMBER"].to_i
    example.run
  end

  config.filter_run_excluding :ci_only unless ENV["GITHUB_ACTIONS"]
end
