require "capybara/rails"
require "capybara/rspec"
require "capybara-screenshot/rspec"
require "selenium/webdriver"

Capybara.register_driver :selenium_chrome_in_container do |app|
  Capybara::Selenium::Driver.new app,
    browser: :remote,
    url: "http://selenium_chrome:4444/wd/hub",
    desired_capabilities: :chrome
end

Capybara.register_driver :selenium_chrome_headless_in_container do |app|
  Capybara::Selenium::Driver.new app,
    browser: :remote,
    url: "http://selenium_chrome:4444/wd/hub",
    desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: {args: %w[headless disable-gpu --window-size=1280,900]}
    )
end

Capybara.register_driver :selenium_chrome_headless do |app|
  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    options: Selenium::WebDriver::Chrome::Options.new(
      args: %w[--headless --disable-gpu --disable-site-isolation-trials --window-size=1280,900]
    )
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    if ENV["DOCKER"]
      driven_by :selenium_chrome_headless_in_container
      Capybara.server_host = "0.0.0.0"
      Capybara.server_port = 4000
      Capybara.app_host = "http://web:4000"
    else
      driven_by :selenium_chrome_headless
    end
  end
end
