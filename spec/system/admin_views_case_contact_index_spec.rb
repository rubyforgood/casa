require "rails_helper"

RSpec.describe "admin views case contacts index page", type: :system do
  let(:organization) { create(:casa_org) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }
  let!(:case_contact) { create(:case_contact, duration_minutes: 105, casa_case: casa_case) }
  let!(:admin) { create(:casa_admin, casa_org: organization) }

  before(:each) {
    sign_in admin
    visit case_contacts_path
  }

  include_examples "scrollable table formatting", ".case-contacts-table"
end
