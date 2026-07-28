require "rails_helper"

RSpec.describe "casa_org/edit", type: :system do
  it "can update show_driving_reimbursement flag" do
    organization = create(:casa_org)
    admin = create(:casa_admin, casa_org_id: organization.id)

    sign_in admin
    visit edit_casa_org_path(organization)

    uncheck "Show driving reimbursement"
    click_on "Submit"
    expect(page).not_to have_checked_field("Show driving reimbursement")

    check "Show driving reimbursement"
    click_on "Submit"
    expect(page).to have_checked_field("Show driving reimbursement")
  end

  it "can upload a logo image" do
    organization = create(:casa_org)
    admin = create(:casa_admin, casa_org: organization)

    stub_twilio
    sign_in admin
    visit edit_casa_org_path(organization)

    page.attach_file("Logo", file_fixture("company_logo.png"), visible: :visible)

    click_on "Submit"

    expect(page).to have_content("CASA organization was successfully updated.")
  end

  it "hides Twilio Form if twilio is not enabled", :js do
    organization = create(:casa_org, twilio_enabled: true)
    admin = create(:casa_admin, casa_org: organization)

    sign_in admin
    visit edit_casa_org_path(organization)

    uncheck "Enable Twilio"
    expect(page).to have_selector("#casa_org_twilio_account_sid", visible: :hidden)
    expect(page).to have_selector("#casa_org_twilio_api_key_sid", visible: :hidden)
    expect(page).to have_selector("#casa_org_twilio_api_key_secret", visible: :hidden)
    expect(page).to have_selector("#casa_org_twilio_phone_number", visible: :hidden)
  end

  it "displays Twilio Form when Enable Twilio is checked" do
    organization = create(:casa_org, twilio_enabled: true)
    admin = create(:casa_admin, casa_org: organization)

    sign_in admin
    visit edit_casa_org_path(organization)

    expect(page).to have_text("Enable Twilio")
    expect(page).to have_selector("#casa_org_twilio_account_sid", visible: :visible)
    expect(page).to have_selector("#casa_org_twilio_api_key_sid", visible: :visible)
    expect(page).to have_selector("#casa_org_twilio_api_key_secret", visible: :visible)
    expect(page).to have_selector("#casa_org_twilio_phone_number", visible: :visible)
  end

  it "requires Twilio Form to be filled in correctly", :js do
    organization = create(:casa_org, twilio_enabled: true)
    admin = create(:casa_admin, casa_org: organization)

    sign_in admin
    visit edit_casa_org_path(organization)

    fill_in "Twilio Phone Number", with: ""
    click_on "Submit"

    expect(page).to have_css("#casa_org_twilio_phone_number:invalid")
  end
end
