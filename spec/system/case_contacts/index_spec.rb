require "rails_helper"

RSpec.describe "case_contacts/index", type: :system do
  let(:organization) { create(:casa_org) }
  let(:volunteer) { create(:volunteer, display_name: "Bob Loblaw", casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization, case_number: "CINA-1") }
  let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }
  let!(:case_contact) { create(:case_contact, creator: volunteer, casa_case: casa_case) }

  before(:each) do
    sign_in volunteer
    visit case_contacts_path
  end

  it "can see case creator in table" do
    expect(page).to have_text("Bob Loblaw")
  end

  it "can navigate to edit volunteer page" do
    expect(page).to have_no_link("Bob Loblaw")
  end
end
