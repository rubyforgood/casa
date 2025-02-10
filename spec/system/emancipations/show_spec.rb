require "rails_helper"

RSpec.describe "emancipations/show", type: :system do
  let(:org) { build(:casa_org) }
  let(:volunteer) { build(:volunteer, casa_org: org) }
  let(:supervisor) { create(:supervisor, casa_org: org) }
  let(:casa_case) { build(:casa_case, casa_org: org) }
  let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, casa_case: casa_case) }

  it "has a download emancipation checklist button" do
    sign_in volunteer
    visit casa_case_emancipation_path(casa_case)

    expect(page).to have_link "Download Checklist", href: casa_case_emancipation_path(casa_case, format: :docx)
  end

  it "expands the emancipation checklist options", :js do
    emancipation_category = create(:emancipation_category)
    emancipation_option = create(:emancipation_option, emancipation_category: emancipation_category)

    sign_in supervisor
    visit casa_case_emancipation_path(casa_case)

    find(".category-collapse-icon").click
    expect(page).to have_content(emancipation_option.name)
    find(".category-collapse-icon").click
    expect(page).not_to have_content(emancipation_option.name)
  end
end
