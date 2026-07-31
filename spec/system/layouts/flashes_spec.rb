require "rails_helper"

# shared/_flashes: success messages auto-hide, errors do not. The waits here are deliberate -- the
# behaviour under test *is* the timing, so each example waits on a real Capybara matcher rather than
# sleeping.
RSpec.describe "flash messages", :js, type: :system do
  let(:organization) { create(:casa_org) }
  let!(:admin) { create(:casa_admin, casa_org: organization, password: "12345678") }
  let!(:volunteer) { create(:volunteer, casa_org: organization, password: "12345678") }

  # Signing in through the form from a protected page is the one flow that produces Devise's
  # "Signed in successfully." notice: ApplicationController's Accessible#check_user clears the flash
  # and short-circuits Devise's create unless session[:user_return_to] is set.
  def sign_in_via_form(user)
    visit casa_cases_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "12345678"
    click_on "Sign in"
    # Wait for the sign-in to land before anything else navigates. Without this the next `visit`
    # races the POST's redirect, and whichever wins decides whether the page under test -- and its
    # flash -- is the one asserted against. Devise returns us to the stored path (the protected page
    # we started from), so that is the signal.
    expect(page).to have_current_path(casa_cases_path, ignore_query: true)
  end

  # design.md rules out bare floating icons for status, so the severity icon has a filled tile and the
  # message is nudged to the tile's centre line (measured 0.5px apart) rather than the tile pulled up
  # into the card's padding.
  it "grounds the severity icon in a filled tile aligned to the message" do
    sign_in_via_form(admin)

    flash = page.find(".header-flash .alert")
    tile = flash.find("span[aria-hidden='true']")
    expect(tile[:class]).to include("rounded-xl", "bg-emerald-700", "text-white", "h-8", "w-8")
    expect(tile).to have_css("i.bi-check-circle", visible: :all)
  end

  it "auto-dismisses a success notice" do
    sign_in_via_form(admin)

    expect(page).to have_css(".header-flash .alert", text: "Signed in successfully.")
    expect(page).to have_no_css(".header-flash .alert", wait: 12)
  end

  it "holds a success notice while the pointer is over it" do
    sign_in_via_form(admin)
    flash = page.find(".header-flash .alert")

    page.execute_script("arguments[0].dispatchEvent(new MouseEvent('mouseenter'))", flash.native)

    # Waits the full window for a disappearance that must not happen while hovered.
    expect(page).not_to have_no_css(".header-flash .alert", wait: 9)

    page.execute_script("arguments[0].dispatchEvent(new MouseEvent('mouseleave'))", flash.native)
    expect(page).to have_no_css(".header-flash .alert", wait: 12)
  end

  it "leaves an authorization error on screen" do
    sign_in_via_form(volunteer)
    visit casa_admins_path

    error = page.find(".header-flash .alert", text: "you are not authorized")
    expect(error[:role]).to eq "alert"
    expect(error[:"data-controller"]).to be_nil
    expect(page).not_to have_no_css(".header-flash .alert", wait: 9)
  end
end
