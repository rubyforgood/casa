require "simplecov"
require "pry"
SimpleCov.start do
  track_files "{app,lib}/**/*.rb"
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
  config.formatter = :documentation

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
