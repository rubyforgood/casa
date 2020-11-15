require "rails_helper"

RSpec.describe "admin views case details", type: :system do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin, casa_org: organization) }
  let(:volunteer) { create(:volunteer, display_name: "Bob Loblaw", casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization, case_number: "CINA-1") }
  let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }
  let!(:case_contact) { create(:case_contact, creator: volunteer, casa_case: casa_case) }

  before(:each) do
    sign_in admin
    visit casa_case_path(casa_case.id)
  end

  it "can see case creator in table" do
    expect(page).to have_text("Bob Loblaw")
  end

  it "can navigate to edit volunteer page" do
    expect(page).to have_link("Bob Loblaw", href: "/volunteers/#{volunteer.id}/edit")
  end
end
