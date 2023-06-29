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

  it "loads casa org edit page" do
    expect(page).to have_text "Editing CASA Organization"
    expect(page).to_not have_text "sign in before continuing"
  end

  it "has contact type groups content" do
    expect(page).to have_text("Contact type group 1")
    expect(page).to have_text(contact_type_group.name)
  end

  it "has contact type groups table", js: true do
    scroll_to(page.find("table#contact-type-groups", visible: false))
    expect(page).to have_table(
      id: "contact-type-groups",
      with_rows:
      [
        ["Contact type group 1", "Yes", "Edit"]
      ]
    )
  end

  it "has contact types content" do
    expect(page).to have_text("Contact type 1")
    expect(page).to have_text(contact_type.name)
  end

  it "has contact types table", js: true do
    scroll_to(page.find("table#contact-types", visible: false))
    expect(page).to have_table(
      id: "contact-types",
      with_rows:
      [
        ["Contact type 1", "Yes", "Edit"]
      ]
    )
  end

  it "has hearing types content" do
    expect(page).to have_text("Spec Test Hearing Type")
    expect(page).to have_text(hearing_type.name)
  end

  it "has hearing types table", js: true do
    scroll_to(page.find("table#hearing-types", visible: false))
    expect(page).to have_table(
      id: "hearing-types",
      with_rows:
      [
        ["Spec Test Hearing Type", "Yes", "Edit"]
      ]
    )
  end

  it "has judge content" do
    expect(page).to have_text(judge.name)
  end

  it "has sent email content" do
    expect(page).to have_text(sent_email.sent_address)
  end

  it "has sent emails table", js: true do
    travel_to DateTime.new(2021, 1, 2, 12, 30, 0) do
      create(:sent_email, casa_org: organization, user: admin)
    end

    visit edit_casa_org_path(organization)

    scroll_to(page.find("table#sent-emails", visible: false))
    expect(page).to have_table(id: "sent-emails")
    expect(page).to have_table(
      id: "sent-emails",
      with_rows:
      [
        ["Mailer Type", "Mail Action Category", admin.email, "12:30pm 02 Jan 2021"]
      ]
    )
  end

  it "can update show_driving_reimbursement flag" do
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
    uncheck "Enable Twilio" # Casa Org factory set to enable_twilio: true

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
