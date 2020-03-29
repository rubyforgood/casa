require 'rails_helper'

RSpec.describe 'case_updates/show', type: :view do
  before(:each) do
    @case_update = assign(:case_update, CaseUpdate.create!(
                                          user: nil,
                                          casa_case: nil,
                                          update_type: 'Update Type',
                                          other_type_text: 'Other Type Text'
                                        ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Update Type/)
    expect(rendered).to match(/Other Type Text/)
  end
end
