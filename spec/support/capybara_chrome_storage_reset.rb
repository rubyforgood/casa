# Temporary workaround for https://github.com/teamcapybara/capybara/issues/2865
#
# Capybara 3.40.0's ChromeDriver#reset! ends with
#   execute_cdp("Storage.clearDataForOrigin", origin: "*", ...)
# and Chrome 158 rejects "*" ("invalid argument: * is not a valid URL"), which
# fails every JS system spec in its after-hook.
#
# Replace only that call: clear all cookies, and clear local storage for the
# test app's origin. Local storage on any other origin a spec visits is not
# cleared (Capybara previously cleared it for every origin).
#
# Remove this file once Capybara releases a fix (see the issue above).
module CapybaraChromeStorageReset
  def execute_cdp(cmd, params = {})
    return super unless cmd == "Storage.clearDataForOrigin" && params[:origin] == "*"

    super("Network.clearBrowserCookies")

    types = params[:storageTypes].to_s.split(",") - ["cookies"]
    origin = Capybara.app_host || Capybara.current_session.server&.base_url
    return if types.empty? || origin.nil?

    super("Storage.clearDataForOrigin", {origin: origin.to_s.chomp("/"), storageTypes: types.join(",")})
  end
end

# execute_cdp lives in the module Capybara extends onto each Chrome driver, so
# the patch must be prepended there (not onto Capybara::Selenium::Driver).
Capybara::Selenium::Driver::ChromeDriver.prepend(CapybaraChromeStorageReset)
