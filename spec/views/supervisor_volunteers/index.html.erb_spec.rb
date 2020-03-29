require 'rails_helper'

RSpec.describe 'supervisor_volunteers/index', type: :view do
  before(:each) do
    assign(:supervisor_volunteers, [
             SupervisorVolunteer.create!(
               volunteer_id: '',
               supervisor_id: ''
             ),
             SupervisorVolunteer.create!(
               volunteer_id: '',
               supervisor_id: ''
             )
           ])
  end

  it 'renders a list of supervisor_volunteers' do
    render
    assert_select 'tr>td', text: ''.to_s, count: 2
    assert_select 'tr>td', text: ''.to_s, count: 2
  end
end
