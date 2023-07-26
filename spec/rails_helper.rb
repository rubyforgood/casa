require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__) # Prevent database truncation in production. Local? Try RAILS_ENV=test
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!
require "pundit/rspec"
require "view_component/test_helpers"
require "capybara/rspec"

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
  config.include CsvExporterHelper, type: :model
  config.include TemplateHelper
  config.include Warden::Test::Helpers
  config.include ViewComponent::TestHelpers, type: :component
  config.include ViewComponent::SystemTestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component

  config.after do
    Warden.test_reset!
  end

  Shoulda::Matchers.configure do |shoulda_config|
    shoulda_config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

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
end
