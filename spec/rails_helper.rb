require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__) # Prevent database truncation in production. Local? Try RAILS_ENV=test
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!
require "pundit/rspec"
require "webdrivers" unless ENV["DOCKER"]

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
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include PunditHelper, type: :view
  config.include Warden::Test::Helpers
  config.include Organizational, type: :helper
  config.include SessionHelper, type: :view
  config.include SessionHelper, type: :request
  config.include Organizational, type: :view
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

  config.example_status_persistence_file_path = "#{::Rails.root}/tmp/persistent_examples.txt"

  config.filter_rails_from_backtrace!
end


# Returns a hash of _specified_ (as opposed to runtime-adjusted/overridden) CSS attributes for an element
def specified_style_attributes(capybara_element)
  style_string = capybara_element['style']
  attribute_strings = style_string.split(';')
  attribute_strings.each_with_object({}) do |string, style_hash|
    first_colon_position = string.index(':')
    key = string[0...first_colon_position].strip
    value = string[(first_colon_position+1)..-1].strip
    style_hash[key] = value
  end
end