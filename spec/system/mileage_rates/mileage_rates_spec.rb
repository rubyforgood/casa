require "rails_helper"

RSpec.describe "mileage_rates/new", type: :system, js: true do
  let(:admin) { create(:casa_admin) }
  let(:organization) { admin.casa_org }

  before do
    sign_in admin

    visit mileage_rates_path
  end

  it "add new mileage rate" do
    click_on "New Mileage Rate"
    expect(page).to have_text("New Mileage Rate")
    fill_in "Effective date", with: "01/02/2020"
    fill_in "Amount", with: 1.35
    uncheck "Currently active?"
    click_on "Save Mileage Rate"

    expect(page).to have_text("Mileage Rates")
    expect(page).to have_text("Effective date")
    expect(page).to have_text("February 1, 2020")
    expect(page).to have_text("Amount")
    expect(page).to have_text("$1.35")
    expect(page).to have_text("Active?")
    expect(page).to have_text("No")
    expect(page).to have_text("Actions")
    expect(page).to have_text("Edit")
  end
end
