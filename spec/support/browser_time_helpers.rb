# frozen_string_literal: true

module BrowserTimeHelpers
  # Today as YYYY-MM-DD in the BROWSER's zone -- what a field filled by JS holds. `travel_to` freezes
  # Ruby's clock, not the browser's, so a JS-set "today" cannot be asserted against Date.current.
  # Mirrors court_report_controller's localToday(), and is zone-independent so it holds wherever the
  # suite's Chrome runs.
  def browser_today
    page.evaluate_script(<<~JS)
      (function () {
        const now = new Date()
        return new Date(now.getTime() - now.getTimezoneOffset() * 60000).toISOString().slice(0, 10)
      })()
    JS
  end
end

RSpec.configure do |config|
  config.include BrowserTimeHelpers, type: :system
end
