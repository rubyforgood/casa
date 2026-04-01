require "rails_helper"

RSpec.describe "Case Contact Table Row Expansion", type: :system, js: true do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }
  let(:contact_topic) { create(:contact_topic, casa_org: organization, question: "What was discussed?") }
  let!(:case_contact) do
    create(:case_contact, :active, casa_case: casa_case, notes: "Important follow-up needed")
  end

  before do
    create(:contact_topic_answer,
      case_contact: case_contact,
      contact_topic: contact_topic,
      value: "Youth is doing well in school")
    allow(Flipper).to receive(:enabled?).with(:new_case_contact_table).and_return(true)
    sign_in admin
    visit case_contacts_new_design_path
  end

  it "shows the expanded content after clicking the chevron" do
    find(".expand-toggle").click

    expect(page).to have_content("What was discussed?")
    expect(page).to have_content("Youth is doing well in school")
  end

  it "shows notes in the expanded content" do
    find(".expand-toggle").click

    expect(page).to have_content("Additional Notes")
    expect(page).to have_content("Important follow-up needed")
  end

  it "hides the expanded content after clicking the chevron again" do
    find(".expand-toggle").click
    expect(page).to have_content("Youth is doing well in school")

    find(".expand-toggle").click
    expect(page).to have_no_content("Youth is doing well in school")
  end
end
