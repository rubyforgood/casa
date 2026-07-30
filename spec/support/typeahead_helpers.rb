# frozen_string_literal: true

# Driving a searchable-select (TomSelect) control from a system spec.
module TypeaheadHelpers
  # Picks an option from a searchable-select, or straight from the native <select> under rack_test --
  # with no JS the untouched select is still rendered, so one call covers both drivers (several
  # examples share a sign-in-and-assign helper across a :js and a non-:js example).
  #
  # Addressed through the native `<select>`, never `.ts-control` / `.ts-dropdown`: neither is scoped to
  # a control and these pages hold two or more. The menu itself is looked up unscoped on purpose --
  # these pickers can render it on `<body>` to escape an overflow-hidden card, and only the open one is
  # visible.
  def choose_typeahead_option(option_text, select_css:)
    # Options render honorific-free names (`formatted_name`), so match on the stripped text: a caller
    # naturally passes the record's `display_name`, and Faker sometimes prefixes it with "Dr."/"Rev.".
    label = NamePresentation.strip_honorific(option_text)
    select_element = find(select_css, visible: :all)

    if Capybara.current_driver == :rack_test
      select_element.find("option", text: label, match: :first).select_option
      return
    end

    expect(page).to have_css("#{select_css}.tomselected", visible: :all) # waits for TomSelect to mount
    page.execute_script("document.querySelector(#{select_css.to_json}).tomselect.open()")
    find(".ts-dropdown .option", text: label, match: :first).click
    expect(select_element.value).to be_present
  end
end

RSpec.configure do |config|
  config.include TypeaheadHelpers, type: :system
end
