require 'rails_helper'

RSpec.describe 'case_assignments/index', type: :view do
  before do
    assign(:case_assignments, [
             CaseAssignment.create!(
               volunteer_id: 2,
               casa_case_id: '',
               is_active: false
             ),
             CaseAssignment.create!(
               volunteer_id: 2,
               casa_case_id: '',
               is_active: false
             )
           ])
  end

  it 'renders a list of case_assignments' do
    render
    assert_select 'tr>td', text: 2.to_s, count: 2
    assert_select 'tr>td', text: ''.to_s, count: 2
    assert_select 'tr>td', text: false.to_s, count: 2
  end
end
