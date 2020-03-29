require 'rails_helper'

RSpec.describe 'casa_orgs/edit', type: :view do
  before do
    @casa_org = assign(:casa_org, CasaOrg.create!(
                                    name: 'MyString'
                                  ))
  end

  it 'renders the edit casa_org form' do
    render

    assert_select 'form[action=?][method=?]', casa_org_path(@casa_org), 'post' do # rubocop:todo RSpec/InstanceVariable
      assert_select 'input[name=?]', 'casa_org[name]'
    end
  end
end
