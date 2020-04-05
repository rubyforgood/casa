require 'rails_helper'

RSpec.describe CasaCase, type: :model do
  subject { build(:casa_case) }
  it { is_expected.to have_many(:case_assignments) }
  it { is_expected.to validate_presence_of(:case_number) }
  it { is_expected.to validate_uniqueness_of(:case_number).case_insensitive }
  it { is_expected.to have_many(:volunteers).through(:case_assignments) }
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