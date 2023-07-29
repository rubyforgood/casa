require "rails_helper"

RSpec.describe "casa_org/edit", type: :system do
  let(:organization) { build(:casa_org) }
  let!(:languages) do
    5.times { create(:language, name: Faker::Nation.unique.language, casa_org: organization) }
  end
  let(:admin) { build(:casa_admin, casa_org_id: organization.id) }
  let!(:contact_type_group) { create(:contact_type_group, casa_org: organization, name: "Contact type group 1") }
  let!(:contact_type) { create(:contact_type, name: "Contact type 1") }
  let!(:hearing_type) { create(:hearing_type, casa_org: organization, name: "Spec Test Hearing Type") }
  let!(:judge) { create(:judge, casa_org: organization, name: "Joey Tom") }
  let!(:sent_email) { create(:sent_email, casa_org: organization, user: admin) }

  before do
    stub_twillio
    sign_in admin
    visit edit_casa_org_path(organization)
    Faker::Nation.unique.clear # Clears used values for Faker::Nation
  end

  it "can update show_driving_reimbursement flag", js: true do
    check "Show driving reimbursement"
    click_on "Submit"
    has_no_checked_field? "Show driving reimbursement"

    check "Show driving reimbursement"
    click_on "Submit"
    has_checked_field? "Show driving reimbursement"
  end

  it "can upload a logo image", :aggregate_failure do
    page.attach_file("Logo", "spec/fixtures/company_logo.png", make_visible: true)

    expect(organization.logo.attachment).to be_nil

    click_on "Submit"

    expect(organization.reload.logo.attachment).not_to be_nil
  end

  it "hides Twilio Form if twilio is not enabled", js: true do
    uncheck "Enable Twilio"
    # Casa Org factory set to enable_twilio: true
    expect(page).to have_selector("#casa_org_twilio_account_sid", visible: :hidden)
    expect(page).to have_selector("#casa_org_twilio_api_key_sid", visible: :hidden)
    expect(page).to have_selector("#casa_org_twilio_api_key_secret", visible: :hidden)
    expect(page).to have_selector("#casa_org_twilio_phone_number", visible: :hidden)
  end

  it "displays Twilio Form when Enable Twilio is checked", js: true do
    # Casa Org factory set to enable_twilio: true
    expect(page).to have_text("Enable Twilio")
    expect(page).to have_selector("#casa_org_twilio_account_sid", visible: :visible)
    expect(page).to have_selector("#casa_org_twilio_api_key_sid", visible: :visible)
    expect(page).to have_selector("#casa_org_twilio_api_key_secret", visible: :visible)
    expect(page).to have_selector("#casa_org_twilio_phone_number", visible: :visible)
  end

  it "requires Twilio Form to be filled in correctly", js: true do
    fill_in "Twilio Phone Number", with: ""
    click_on "Submit"

    message = find("#casa_org_twilio_phone_number").native.attribute("validationMessage")
    expect(message).to eq "Please fill out this field."
  end

  describe "additional expense feature flag" do
    context "enabled" do
      before do
        FeatureFlagService.enable!(FeatureFlagService::SHOW_ADDITIONAL_EXPENSES_FLAG)
        visit edit_casa_org_path(organization)
      end

      it "has option to enable additional expenses" do
        expect(page).to have_text("Volunteers can add Other Expenses")
      end
    end

    context "disabled" do
      before do
        FeatureFlagService.disable!(FeatureFlagService::SHOW_ADDITIONAL_EXPENSES_FLAG)
        visit edit_casa_org_path(organization)
      end

      it "has option to enable additional expenses" do
        expect(page).not_to have_text("Volunteers can add Other Expenses")
      end
    end
  end

  it "requires name text field" do
    expect(page).to have_selector("input[required=required]", id: "casa_org_name")
  end
end

def stub_twillio
  twillio_client = instance_double(Twilio::REST::Client)
  messages = instance_double(Twilio::REST::Api::V2010::AccountContext::MessageList)
  allow(Twilio::REST::Client).to receive(:new).with("Aladdin", "open sesame", "articuno34").and_return(twillio_client)
  allow(twillio_client).to receive(:messages).and_return(messages)
  allow(messages).to receive(:list).and_return([])
end
