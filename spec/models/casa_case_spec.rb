require 'rails_helper'

RSpec.describe CasaCase do
  subject { build(:casa_case) }

  it { is_expected.to have_many(:case_assignments) }
  it { is_expected.to validate_presence_of(:case_number) }
  it { is_expected.to validate_uniqueness_of(:case_number).case_insensitive }
  it { is_expected.to have_many(:volunteers).through(:case_assignments) }

  describe 'ordered' do
    it 'orders the casa cases by updated at date' do
      very_old_casa_case = create(:casa_case, updated_at: 5.days.ago)
      old_casa_case = create(:casa_case, updated_at: 1.day.ago)
      new_casa_case = create(:casa_case)

      ordered_casa_cases = described_class.ordered

      expect(ordered_casa_cases).to eq [new_casa_case, old_casa_case, very_old_casa_case]
    end
  end

  describe 'actively_assigned_to' do
    it 'only returns cases actively assigned to a volunteer' do
      current_user = create(:user)
      inactive_case = create(:casa_case)
      create(:case_assignment, casa_case: inactive_case, volunteer: current_user, is_active: false)
      active_cases = create_list(:casa_case, 2)
      active_cases.each do |casa_case|
        create(:case_assignment, casa_case: casa_case, volunteer: current_user, is_active: true)
      end

      other_user = create(:user)
      other_active_case = create(:casa_case)
      other_inactive_case = create(:casa_case)
      create(:case_assignment, casa_case: other_active_case, volunteer: other_user, is_active: true)
      create(
        :case_assignment,
        casa_case: other_inactive_case, volunteer: other_user, is_active: false
      )

      assert_equal active_cases, described_class.actively_assigned_to(current_user)
    end
  end
end
