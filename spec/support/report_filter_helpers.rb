# frozen_string_literal: true

# Drive the reports page's TomSelect multi-select filters by the native <select> id.
# TomSelect hides the native <select>, so Capybara's `select .. from:` / `have_select` no longer
# reach it -- interact through the rendered .ts-control (open the control, click the option) instead.
module ReportFilterHelpers
  def select_report_filter_option(select_id, option)
    field = find("##{select_id}", visible: :all).ancestor("[data-controller='multiple-select']")
    field.find(".ts-control").click
    field.find("div.option", text: option, match: :first).click
  end
end

RSpec.configure do |config|
  config.include ReportFilterHelpers, type: :system
end
