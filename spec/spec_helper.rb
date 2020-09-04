require "simplecov"
require "capybara/rspec"
require "pundit/rspec"
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

  config.before(:each, type: :system) do
    driven_by :selenium_chrome_headless
  end
end
