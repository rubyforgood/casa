require 'rails_helper'

RSpec.describe 'casa_cases/index', type: :view do
  before do
    assign(:casa_cases, [
             CasaCase.create!(
               case_number: 'Case Number',
               teen_program_eligible: false
             ),
             CasaCase.create!(
               case_number: 'Case Number',
               teen_program_eligible: false
             )
           ])
  end

  it 'renders a list of casa_cases' do
    render
    assert_select 'tr>td', text: 'Case Number'.to_s, count: 2
    assert_select 'tr>td', text: false.to_s, count: 2
  end
end
