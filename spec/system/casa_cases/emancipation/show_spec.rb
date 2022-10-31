require "rails_helper"

RSpec.describe "casa_cases/show", type: :system do
  let(:organization) { build(:casa_org) }
  let(:volunteer) { build(:volunteer, casa_org: organization) }
  let(:casa_case) { build(:casa_case, casa_org: organization) }
  let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }
  let!(:emancipation_category) { build(:emancipation_category, mutually_exclusive: true) }
  let!(:emancipation_option) { create(:emancipation_option, emancipation_category: emancipation_category) }
  let(:supervisor) { create(:supervisor, casa_org: organization) }

  before do
    sign_in user
    visit casa_case_emancipation_path(casa_case.id)
  end

  context "volunteer user", js: true do
    let(:user) { volunteer }

    it "sees title" do
      expect(page).to have_content("Emancipation Checklist")

      expect(page).to have_content(emancipation_category.name)
      expect(page).to_not have_content(emancipation_option.name)

      find(".emancipation-category").click # Open list of options for this category
      expect(page).to have_content(emancipation_option.name) # Make sure list of options is showing
      find(".check-item").click # Select the first option
      find(".emancipation-category").click # Close the list of options for this category
      # TODO fix flakiness
      expect(page).to have_css(".async-success-indicator", text: "Unchecked #{emancipation_option.name}")

      # TODO more asserts here - checking and unchecking items
    end
  end
end
