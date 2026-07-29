require "rails_helper"

RSpec.describe "mileage_rates/new", :js, type: :system do
  let(:admin) { create(:casa_admin) }
  let(:organization) { admin.casa_org }

  before do
    sign_in admin

    visit mileage_rates_path
  end

  it "add new mileage rate" do
    click_on "New mileage rate"
    expect(page).to have_text("New mileage rate")
    fill_in "Effective date", with: Date.new(2020, 1, 2)
    fill_in "Amount", with: 1.35
    uncheck "Currently active?"
    click_on "Save mileage rate"

    expect(page).to have_text("Mileage rates")
    # Column headers render in sentence case (no uppercase transform); matched case-insensitively defensively.
    expect(page).to have_text(/Effective date/i)
    expect(page).to have_text("January 2, 2020")
    expect(page).to have_text(/Amount/i)
    expect(page).to have_text("$1.35")
    expect(page).to have_text(/Active\?/i)
    expect(page).to have_text("No")
    expect(page).to have_text(/Actions/i)
    expect(page).to have_text("Edit")
  end
end
