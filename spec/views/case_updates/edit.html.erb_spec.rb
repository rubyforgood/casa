require 'rails_helper'

RSpec.describe 'case_updates/edit', type: :view do
  before do
    @case_update = assign(:case_update, CaseUpdate.create!(
                                          user: nil,
                                          casa_case: nil,
                                          update_type: 'MyString',
                                          other_type_text: 'MyString'
                                        ))
  end

  it 'renders the edit case_update form' do # rubocop:todo RSpec/ExampleLength
    render

    assert_select 'form[action=?][method=?]', case_update_path(@case_update), 'post' do # rubocop:todo RSpec/InstanceVariable
      assert_select 'input[name=?]', 'case_update[user_id]'

      assert_select 'input[name=?]', 'case_update[casa_case_id]'

      assert_select 'input[name=?]', 'case_update[update_type]'

      assert_select 'input[name=?]', 'case_update[other_type_text]'
    end
  end
end
