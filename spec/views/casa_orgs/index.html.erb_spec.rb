require 'rails_helper'

RSpec.describe 'casa_orgs/index', type: :view do
  before do
    assign(:casa_orgs, [
             CasaOrg.create!(
               name: 'Name'
             ),
             CasaOrg.create!(
               name: 'Name'
             )
           ])
  end

  it 'renders a list of casa_orgs' do
    render
    assert_select 'tr>td', text: 'Name'.to_s, count: 2
  end
end
