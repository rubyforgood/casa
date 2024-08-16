require 'rails_helper'

RSpec.describe 'placements/index', type: :view do
  subject { render template: "placements/edit" }

  let(:casa_case) { create(:casa_case, case_number: 'CINA-12345') }
  let(:placement_type_current) { create(:placement_type, name: 'Reunification') }
  let(:placement_type_prev) { create(:placement_type, name: 'Custody/Guardianship by a relative') }
  let(:placement_type_first) { create(:placement_type, name: 'APPLA') }

  let(:placements) do
    [
      create(:placement, placement_started_at: '2024-08-15 20:40:44 UTC', casa_case:, placement_type: placement_type_current),
      create(:placement, placement_started_at: '2023-06-02 00:00:00 UTC', casa_case:, placement_type: placement_type_prev),
      create(:placement, placement_started_at: '2021-12-25 10:10:10 UTC', casa_case:, placement_type: placement_type_first)
    ]
  end

  before do
    assign(:casa_case, casa_case)
    assign(:placements, placements.sort_by(&:placement_started_at).reverse)

    render
  end

  it 'displays the case number in the header' do
    expect(rendered).to have_selector('h1', text: "CINA-12345")
  end

  it 'has a link to create a new placement' do
    expect(rendered).to have_link('New Placement', href: new_casa_case_placement_path(casa_case))
  end

  it 'displays placement information for each placement' do
    expect(rendered).to have_content('Reunification')
    expect(rendered).to have_content(/August 15, 2024\s*-\s*Present/)

    expect(rendered).to have_content('Custody/Guardianship by a relative')
    expect(rendered).to have_content(/June 02, 2023\s*-\s*August 14, 2024/)

    expect(rendered).to have_content('APPLA')
    expect(rendered).to have_content(/December 25, 2021\s*-\s*June 01, 2023/)
  end

  it 'has edit links for each placement' do
    placements.each do |placement|
      expect(rendered).to have_link('Edit', href: edit_casa_case_placement_path(casa_case, placement))
    end
  end

  it 'has delete buttons for each placement' do
    placements.each do |placement|
      expect(rendered).to have_selector("a[data-bs-target='##{placement.id}']", text: 'Delete')
    end
  end

  it 'renders delete confirmation modals for each placement' do
    placements.each do |placement|
      expect(rendered).to have_selector("##{placement.id}.modal")
      within "##{placement.id}" do
        expect(rendered).to have_content('Delete Placement?')
        expect(rendered).to have_link('Delete Placement', href: casa_case_placement_path(casa_case, placement))
      end
    end
  end
end