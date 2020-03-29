require 'rails_helper'

RSpec.describe 'casa_cases/show', type: :view do
  before do
    @casa_case = assign(:casa_case, CasaCase.create!(
                                      case_number: 'Case Number',
                                      teen_program_eligible: false
                                    ))
  end

  it 'renders attributes in <p>' do # rubocop:todo RSpec/MultipleExpectations
    render
    expect(rendered).to match(/Case Number/)
    expect(rendered).to match(/false/)
  end
end
