require "rails_helper"

RSpec.describe "placements/index", type: :view do
  let(:casa_org) { create(:casa_org, :with_placement_types) }
  let(:casa_case) { create(:casa_case, casa_org:, case_number: "CINA-12345") }
  let(:placement_current) { create(:placement_type, name: "Reunification", casa_org:) }
  let(:placement_prev) { create(:placement_type, name: "Kinship", casa_org:) }
  let(:placement_first) { create(:placement_type, name: "Adoption", casa_org:) }

  let(:placements) do
    [
      create(:placement, placement_started_at: "2024-08-15 20:40:44 UTC", casa_case:, placement_type: placement_current),
      create(:placement, placement_started_at: "2023-06-02 00:00:00 UTC", casa_case:, placement_type: placement_prev),
      create(:placement, placement_started_at: "2021-12-25 10:10:10 UTC", casa_case:, placement_type: placement_first)
    ]
  end

  before do
    assign(:casa_case, casa_case)
    assign(:placements, placements.sort_by(&:placement_started_at).reverse)

    render
  end

  it "displays the case number in the header" do
    expect(rendered).to have_selector("h1", text: "CINA-12345")
  end

  it "has a link to create a new placement" do
    expect(rendered).to have_link("New Placement", href: new_casa_case_placement_path(casa_case))
  end

  it "displays placement information for each placement" do
    expect(rendered).to have_content("Reunification")
    expect(rendered).to have_content(/August 15, 2024/)
    expect(rendered).to have_content(/Present/)

    expect(rendered).to have_content("Kinship")
    expect(rendered).to have_content(/June 2, 2023/)

    expect(rendered).to have_content("Adoption")
    expect(rendered).to have_content(/December 25, 2021/)
  end

  it "has edit links for each placement" do
    placements.each do |placement|
      expect(rendered).to have_link("Edit", href: edit_casa_case_placement_path(casa_case, placement))
    end
  end

  it "has delete buttons for each placement" do
    placements.each do |placement|
      expect(rendered).to have_selector("a[data-bs-target='##{placement.id}']", text: "Delete")
    end
  end

  it "renders delete confirmation modals for each placement" do
    placements.each do |placement|
      expect(rendered).to have_selector("##{placement.id}.modal")
      within "##{placement.id}" do
        expect(rendered).to have_content("Delete Placement?")
        expect(rendered).to have_link("Delete Placement", href: casa_case_placement_path(casa_case, placement))
      end
    end
  end
end
