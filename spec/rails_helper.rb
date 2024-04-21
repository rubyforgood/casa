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
require "quarantine"
require "rspec/retry"

# Require all support folder files
Dir[Rails.root.join("spec", "support", "**", "*.rb")].sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

Quarantine::RSpecAdapter.bind if ENV["CI"]
WebMock.disable_net_connect!(allow: %w[www.googleapis.com sheets.googleapis.com])

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

  config.filter_rails_from_backtrace!

  config.disable_monkey_patching!

  config.around :each, :disable_bullet do |example|
    Bullet.raise = false
    example.run
    Bullet.raise = true
  end

  def pre_transition_aged_youth_age
    Date.current - CasaCase::TRANSITION_AGE.years
  end

  if ENV["CI"]
    config.quarantine_record_tests = true
    config.quarantine_release_at_consecutive_passes = 5
    config.test_statuses_table = ENV["QUARANTINE_DB_TABLE_NAME"]

    config.around(:each) do |example|
      example.run_with_retry(retry: 3)
    end

    file = Tempfile.new
    file.write(ENV["QUARANTINE_SERVICE_ACCOUNT_JSON"].to_json)
    file.rewind
    config.quarantine_database = {
      type: :google_sheets,
      authorization: {type: :service_account_key, file: file.path},
      spreadsheet: {
        type: :by_key,
        key: ENV["QUARANTINE_SHEET_ID"]
      }
    }
  end
end
