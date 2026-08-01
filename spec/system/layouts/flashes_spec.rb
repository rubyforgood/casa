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

  # A plain leading glyph, not a tile: a filled tile shouted on a compact card and added height. The
  # tint and border carry the severity; the glyph inherits the card's ink.
  it "leads with a plain severity glyph, not a tile" do
    sign_in_via_form(admin)

    flash = page.find(".header-flash .alert")
    expect(flash).to have_css("i.bi-check-circle", visible: :all)
    expect(flash).to have_no_css("span[aria-hidden='true']")
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
