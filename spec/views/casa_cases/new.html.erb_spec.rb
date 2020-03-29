require 'rails_helper'

RSpec.describe 'casa_cases/new', type: :view do
  before do
    assign(:casa_case, CasaCase.new(
                         case_number: 'MyString',
                         teen_program_eligible: false
                       ))
  end

  it 'renders new casa_case form' do
    render

    assert_select 'form[action=?][method=?]', casa_cases_path, 'post' do
      assert_select 'input[name=?]', 'casa_case[case_number]'

      assert_select 'input[name=?]', 'casa_case[teen_program_eligible]'
    end
  end
end
