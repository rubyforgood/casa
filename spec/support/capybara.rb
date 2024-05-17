require "capybara/rails"
require "capybara/rspec"
require "capybara-screenshot/rspec"
require "selenium/webdriver"

# not used unless you swap it out for selenium_chrome_headless_in_container to watch tests running in docker
Capybara.register_driver :selenium_chrome_in_container do |app|
  Capybara::Selenium::Driver.new app,
    browser: :remote,
    url: "http://selenium_chrome:4444/wd/hub",
    capabilities: [:chrome]
end

# disable CSS transitions and js animations
Capybara.disable_animation = true

Capybara::Screenshot.autosave_on_failure = true

module Capybara
  module Screenshot
    def self.capybara_tmp_path
      Rails.root.join("tmp", "screenshots#{ENV["GROUPS_UNDERSCORE"]}")
    end
  end
end

options = Selenium::WebDriver::Chrome::Options.new
options.add_argument("--disable-gpu")
options.add_argument("--ignore-certificate-errors")
options.add_argument("--window-size=1280,1900")

options.add_preference(:browser, set_download_behavior: {behavior: "allow"})

# used in docker
Capybara.register_driver :selenium_chrome_headless_in_container do |app|
  options.add_argument("--headless")
  options.add_preference(:download, prompt_for_download: false, default_directory: "/home/seluser/Downloads")
  options.add_argument("--disable-dev-shm-usage")

  Capybara::Selenium::Driver.new app,
    browser: :remote,
    url: "http://selenium_chrome:4444/wd/hub",
    options: options
end

# used without docker
Capybara.register_driver :selenium_chrome_headless do |app|
  options.add_argument("--headless")
  options.add_argument("--disable-site-isolation-trials")
  options.add_preference(:download, prompt_for_download: false, default_directory: DownloadHelpers::PATH.to_s)

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    options: options
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    config.include DownloadHelpers
    clear_downloads
    if ENV["DOCKER"]
      driven_by :selenium_chrome_headless_in_container
      Capybara.server_host = "0.0.0.0"
      Capybara.server_port = 4000
      Capybara.app_host = "http://web:4000"
    else
      driven_by :selenium_chrome_headless
    end
  end

  config.before(:each, type: :system, debug: true) do
    config.include DownloadHelpers
    clear_downloads
    if ENV["DOCKER"]
      driven_by :selenium_chrome_in_container
      Capybara.server_host = "0.0.0.0"
      Capybara.server_port = 4000
      Capybara.app_host = "http://web:4000"
    else
      driven_by :selenium_chrome
    end
  end
end
