require "rails_helper"

RSpec.describe "casa_cases/show", type: :system do
  let(:organization) { create(:casa_org) }
  let(:volunteer) { create(:volunteer, casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }
  let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }
  let!(:emancipation_category) { create(:emancipation_category, mutually_exclusive: true) }
  let!(:emancipation_option) { create(:emancipation_option, emancipation_category: emancipation_category) }

  before do
    sign_in user
    visit casa_case_emancipation_path(casa_case)
  end

  context "volunteer user", :js do
    let(:user) { volunteer }

    it "has a title" do
      expect(page).to have_content("Emancipation checklist")
      expect(page).to have_content(emancipation_category.name)
    end

    it "checks a category to open options, selects an option, and unchecks the category to hide them" do
      category = page.find(".emancipation-category", text: emancipation_category.name)

      expect(category).to have_css(".emancipation-category-check-box:not(:checked)")
      expect(category["data-is-open"]).to eq("false")

      category.find(".emacipation-category-input-label-pair").click

      expect(category).to have_css(".emancipation-category-check-box:checked")
      expect(page).to have_content(emancipation_option.name)
      expect(category["data-is-open"]).to eq("true")
      expect(casa_case.reload.emancipation_categories).to include(emancipation_category)

      find(".check-item", text: emancipation_option.name).click

      expect(page).to have_css(".check-item input:checked")
      expect(casa_case.reload.emancipation_options).to include(emancipation_option)

      category.find(".emacipation-category-input-label-pair").click

      expect(category).to have_css(".emancipation-category-check-box:not(:checked)")
      expect(page).to have_css(".success-notification", text: "Unchecked #{emancipation_option.name}")
      expect(category["data-is-open"]).to eq("false")
      expect(page).to have_css(".category-options", visible: :hidden)
      expect(casa_case.reload.emancipation_categories).not_to include(emancipation_category)
      expect(casa_case.reload.emancipation_options).not_to include(emancipation_option)
    end

    it "toggles a non-exclusive option and persists it" do
      checkbox_category = create(:emancipation_category, mutually_exclusive: false)
      checkbox_option = create(:emancipation_option, emancipation_category: checkbox_category)
      visit casa_case_emancipation_path(casa_case)

      category = page.find(".emancipation-category", text: checkbox_category.name)
      category.find(".emacipation-category-input-label-pair").click
      expect(category).to have_css(".emancipation-category-check-box:checked")

      option = find(".check-item", text: checkbox_option.name)
      option.click
      expect(option).to have_css("input:checked")
      expect(casa_case.reload.emancipation_options).to include(checkbox_option)

      option.click
      expect(option).to have_css("input:not(:checked)")
      expect(casa_case.reload.emancipation_options).not_to include(checkbox_option)
    end

    it "shows and hides the options through collapse icon" do
      emancipation_category_el = page.find(".emancipation-category", text: emancipation_category.name)
      emancipation_category_el.find(".category-collapse-icon").click
      expect(emancipation_category_el["data-is-open"]).to eq("true")
      expect(page).to have_content(emancipation_option.name)
      emancipation_category_el.find(".category-collapse-icon").click
      expect(emancipation_category_el["data-is-open"]).to eq("false")
      expect(page).not_to have_content(emancipation_option.name)
    end
  end
end
