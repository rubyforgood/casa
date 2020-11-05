require "rails_helper"

RSpec.describe "admin or supervisor adds a case contact", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }
  let(:contact_type_group) { create(:contact_type_group, casa_org: organization) }
  let!(:empty) { create(:contact_type_group, name: "Empty", casa_org: organization) }
  let!(:grp_with_hidden) { create(:contact_type_group, name: "OnlyHiddenTypes", casa_org: organization) }
  let!(:hidden_type) { create(:contact_type, name: "Hidden", active: false, contact_type_group: grp_with_hidden) }
  let!(:school) { create(:contact_type, name: "School", contact_type_group: contact_type_group) }
  let!(:therapist) { create(:contact_type, name: "Therapist", contact_type_group: contact_type_group) }

  before do
    sign_in admin

    visit casa_case_path(casa_case.id)
    click_on "New Case Contact"

    check "School"
    check "Therapist"
    choose "Yes"
    select "Video", from: "case_contact[medium_type]"
    fill_in "case_contact_occurred_at", with: "04/04/2020"
  end

  it "is successful" do
    fill_in "case-contact-duration-hours", with: "1"
    fill_in "case-contact-duration-minutes", with: "45"

    expect {
      click_on "Submit"
    }.to change(CaseContact, :count).by(1)

    expect(CaseContact.first.casa_case_id).to eq casa_case.id
    expect(CaseContact.first.contact_types).to match_array([school, therapist])
    expect(CaseContact.first.duration_minutes).to eq 105
  end

  it "does not show empty contact type groups" do
    expect(page).to_not have_text("Empty")
  end

  it "does not show contact type groups with only hidden contact types" do
    expect(page).to_not have_text("Hidden")
  end

  it "should display full text in table if notes are less than 100 characters" do
    fill_in "case-contact-duration-hours", with: "1"
    fill_in "case-contact-duration-minutes", with: "45"

    short_notes = "Hello world!"
    fill_in "Notes", with: short_notes
    click_on "Submit"

    expect(page).to have_text("Confirm Note Content")

    expect {
      click_on "Continue Submitting"
    }.to change(CaseContact, :count).by(1)

    expect(page).to have_text(short_notes)
    expect(page).not_to have_text("Read more")
  end

  it "should allow expanding or hiding if notes are more than 100 characters" do
    fill_in "case-contact-duration-hours", with: "1"
    fill_in "case-contact-duration-minutes", with: "45"

    long_notes = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."\
    "Nullam id placerat eros. Fusce egestas sem facilisis interdum maximus."\
    "Donec ullamcorper ligula et consectetur placerat. Duis vel purus molestie,"\
    "euismod diam pretium, mattis nibh. Fusce eget leo ex. Donec vitae lacus eu"\
    "magna tincidunt placerat. Mauris nibh nibh, venenatis sit amet libero in,"\

    fill_in "Notes", with: long_notes
    click_on "Submit"

    expect(page).to have_text("Confirm Note Content")
    expect {
      click_on "Continue Submitting"
    }.to change(CaseContact, :count).by(1)

    expected_text = long_notes.truncate(100)
    expect(page).to have_text("Read more")
    expect(page).to have_text(expected_text)

    click_link "Read more"

    expect(page).to have_text("Hide")
    expect(page).to have_text(long_notes)
    expect(page).not_to have_text("Read more")
  end

  context "with invalid inputs" do
    it "does not submit the form" do
      fill_in "case-contact-duration-hours", with: "0"
      fill_in "case-contact-duration-minutes", with: "5"

      expect {
        click_on "Submit"
      }.not_to change(CaseContact, :count)
    end
  end
end
