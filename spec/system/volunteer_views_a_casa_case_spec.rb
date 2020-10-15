require "rails_helper"

RSpec.describe "volunteer views a casa case", type: :system do
  let(:volunteer) { create(:volunteer) }
  let(:casa_case) { create(:casa_case, casa_org: volunteer.casa_org) }
  let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }
  let!(:case_contact) { create(:case_contact, casa_case: casa_case) }

  before do
    sign_in volunteer
    visit casa_case_path(casa_case)
  end

  include_examples "scrollable table formatting", ".case-contacts-table"
end
