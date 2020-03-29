require 'rails_helper'

RSpec.describe 'casa_orgs/show', type: :view do
  before do
    @casa_org = assign(:casa_org, CasaOrg.create!(
                                    name: 'Name'
                                  ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Name/)
  end
end
