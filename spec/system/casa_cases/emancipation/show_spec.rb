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

    it "has a title" do
      expect(page).to have_content("Emancipation Checklist")
      expect(page).to have_content(emancipation_category.name)
    end

    it "opens through main input, selects an option, and unselects option through main input" do
      emancipation_category = page.find(".emancipation-category")
      find(".emacipation-category-input-label-pair").click
      expect(page).to have_content(emancipation_option.name)
      expect(emancipation_category["data-is-open"]).to match(/true/)
      find(".check-item").click
      find(".emacipation-category-input-label-pair").click
      expect(page).to have_css(".success-indicator", text: "Unchecked #{emancipation_option.name}")
      expect(emancipation_category["data-is-open"]).to match(/true/)
    end

    it "shows and hides the options through collapse icon" do
      emancipation_category = page.find(".emancipation-category")
      find(".category-collapse-icon").click
      expect(emancipation_category["data-is-open"]).to match(/true/)
      find(".category-collapse-icon").click
      expect(emancipation_category["data-is-open"]).to match(/false/)
    end
  end
end
