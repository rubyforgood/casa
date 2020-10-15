require 'spec_helper'

shared_examples 'scrollable table formatting' do |table_identifier|
  # This test ensures we retain the css workaround
  # to the "DataTables with scroll enabled result in
  # column/header misalignment" bug
  # (see https://datatables.net/manual/tech-notes/6)
  it 'successfully renders the table header and table body as the same width' do
    table_header = all(table_identifier).first
    table_body = all(table_identifier).last

    width = ->(element) { specified_style_attributes(element)["width"] }

    expect(width.call(table_header)).to eq(width.call(table_body))

    # Resize page and check again
    page.driver.browser.manage.window.resize_to(2000, 2000)
    expect(width.call(table_header)).to eq(width.call(table_body))
  end
end
