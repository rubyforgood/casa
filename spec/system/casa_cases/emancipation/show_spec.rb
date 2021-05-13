require "rails_helper"

RSpec.describe "casa_cases/show", :disable_bullet, type: :system do
  let(:organization) { create(:casa_org) }
  let(:volunteer) { create(:volunteer, casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization, transition_aged_youth: true) }
  let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }
  let!(:emancipation_category) { create(:emancipation_category, mutually_exclusive: true) }

  before do
    sign_in user
    visit casa_case_emancipation_path(casa_case.id)
  end

  context "volunteer user" do
    let(:user) { volunteer }

    it "sees title" do
      expect(page).to have_content("Emancipation Checklist")
      # TODO more asserts here - checking and unchecking items
    end
  end
end
