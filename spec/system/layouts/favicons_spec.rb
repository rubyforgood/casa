require "rails_helper"

RSpec.describe "favicons", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:all_casa_admin) { create(:all_casa_admin) }

  # shared/_favicons exists (with every sized asset in app/assets/images) but the migration dropped
  # the include, so no shell linked an icon and only public/favicon.ico was left doing the work.
  def expect_icons
    expect(page).to have_css("link[rel='apple-touch-icon'][sizes='180x180']", visible: :all)
    expect(page).to have_css("link[rel='icon'][sizes='32x32']", visible: :all)
    expect(page).to have_css("meta[name='theme-color']", visible: :all)
  end

  it "links them on the app shell" do
    sign_in admin
    visit authenticated_user_root_path
    expect_icons
  end

  it "links them on the auth shell" do
    visit new_user_session_path
    expect_icons
  end

  it "links them on the all-casa shell" do
    sign_in all_casa_admin
    visit authenticated_all_casa_admin_root_path
    expect_icons
  end

  it "links them on the minimal error shell" do
    visit error_path
    expect_icons
  end
end
