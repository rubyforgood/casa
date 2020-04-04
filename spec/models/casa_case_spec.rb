require 'rails_helper'

RSpec.describe CasaCase, type: :model do
  it do
    is_expected.to(
      belong_to(:volunteer).class_name("User").inverse_of(:casa_cases).optional(true)
    )
  end
end

RSpec.describe  CasaCase, "ordered" do
  it 'orders the casa cases by updated at date' do
    very_old_casa_case = create(:casa_case, updated_at: 5.days.ago)
    old_casa_case = create(:casa_case, updated_at: 1.day.ago)
    new_casa_case = create(:casa_case)

    ordered_casa_cases = CasaCase.ordered

    expect(ordered_casa_cases).to eq [new_casa_case, old_casa_case, very_old_casa_case]
  end
end
