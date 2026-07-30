require "rails_helper"
require "axe-rspec"

RSpec.describe "learning_hours/index date range", :js, type: :system do
  let(:org) { create(:casa_org) }
  let(:supervisor) { create(:supervisor, casa_org: org) }
  let!(:volunteer) { create(:volunteer, casa_org: org, supervisor: supervisor, display_name: "Quinn Quimby") }
  let(:type) { create(:learning_hour_type, casa_org: org) }

  before do
    create(:learning_hour, user: volunteer, learning_hour_type: type, duration_hours: 1, duration_minutes: 0, occurred_at: Date.current)
    create(:learning_hour, user: volunteer, learning_hour_type: type, duration_hours: 2, duration_minutes: 0, occurred_at: 3.years.ago)
    create(:learning_hour, user: volunteer, learning_hour_type: type, duration_hours: 4, duration_minutes: 0, occurred_at: Date.current.beginning_of_year - 1.day)
  end

  it "defaults to the calendar year and honours a chosen range" do
    sign_in supervisor
    visit learning_hours_path

    # The header names the period instead of claiming "this year", and the default really is the
    # calendar year: the 2h from three years ago and the 4h from Dec 31 are excluded.
    expect(find("table thead tr th", text: "Time completed")).to have_text("since #{I18n.l(Date.current.beginning_of_year, format: :full)}")
    expect(find("table tbody tr td:last-child")).to have_text("1 hours")

    # widen the range back to include everything
    # Set the date input via JS: typing into <input type=date> with Selenium is locale-dependent and
    # produced "0730-02-02" from "2021-07-30".
    find("#from").execute_script("this.value = arguments[0]; this.dispatchEvent(new Event('change', {bubbles: true}))", 5.years.ago.to_date.strftime("%Y-%m-%d"))
    expect(page).to have_css("table tbody tr")
    sleep 1
    expect(find("table tbody tr td:last-child")).to have_text("7 hours")
    expect(find("table thead tr th", text: "Time completed")).to have_text("since #{I18n.l(5.years.ago.to_date, format: :full)}")
    expect(page.current_url).to include("from=#{5.years.ago.to_date}")
  end

  it "clamps a nonsense date rather than putting it in the header" do
    sign_in supervisor
    visit learning_hours_path(from: "0730-02-02")

    # Date.parse accepts year 730; without clamping the header read "since February 2, 0730".
    expect(find("table thead tr th", text: "Time completed")).to have_text("since #{I18n.l(Date.new(1989, 1, 1), format: :full)}")
  end
end
