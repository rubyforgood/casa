require "simplecov"
require "pry"
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/lib/tasks/auto_annotate_models.rake"
  add_group "Models", "/app/models"
  add_group "Controllers", "/app/controllers"
  add_group "Channels", "/app/channels"
  add_group "Decorators", "/app/decorators"
  add_group "Helpers", "/app/helpers"
  add_group "Jobs", "/app/jobs"
  add_group "Importers", "/app/lib/importers"
  add_group "Mailers", "/app/mailers"
  add_group "Policies", "/app/policies"
  add_group "Values", "/app/values"
  add_group "Tasks", "/lib/tasks"
  add_group "Config", "/config"
  add_group "Database", "/db"
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  config.before(:each, type: :system) do
    if ENV["DOCKER"]
      driven_by :selenium_chrome_headless_in_container
      Capybara.server_host = "0.0.0.0"
      Capybara.server_port = 4000
      Capybara.app_host = "http://web:4000"
    else
      driven_by :selenium_chrome_headless
    end
  end

  config.before(:each, type: :system, js: false) do
    driven_by :rack_test
  end
end
