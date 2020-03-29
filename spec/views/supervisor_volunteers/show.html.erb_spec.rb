require 'rails_helper'

RSpec.describe 'supervisor_volunteers/show', type: :view do
  before do
    @supervisor_volunteer = assign(:supervisor_volunteer, SupervisorVolunteer.create!(
                                                            volunteer_id: '',
                                                            supervisor_id: ''
                                                          ))
  end

  it 'renders attributes in <p>' do # rubocop:todo RSpec/MultipleExpectations
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
  end
end
