require 'rails_helper'

RSpec.describe 'case_assignments/show', type: :view do
  before do
    @case_assignment = assign(:case_assignment, CaseAssignment.create!(
                                                  volunteer_id: 2,
                                                  casa_case_id: '',
                                                  is_active: false
                                                ))
  end

  it 'renders attributes in <p>' do # rubocop:todo RSpec/MultipleExpectations
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(//)
    expect(rendered).to match(/false/)
  end
end
