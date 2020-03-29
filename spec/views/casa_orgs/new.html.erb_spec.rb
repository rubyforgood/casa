require 'rails_helper'

RSpec.describe 'casa_orgs/new', type: :view do
  before do
    assign(:casa_org, CasaOrg.new(
                        name: 'MyString'
                      ))
  end

  it 'renders new casa_org form' do
    render

    assert_select 'form[action=?][method=?]', casa_orgs_path, 'post' do
      assert_select 'input[name=?]', 'casa_org[name]'
    end
  end
end
