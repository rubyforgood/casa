require 'rails_helper'

RSpec.describe CaseContact, type: :model do
  it { is_expected.to(belong_to(:creator).class_name("User")) }
  it { is_expected.to(belong_to(:casa_case)) }
  it do
    is_expected.to(
      define_enum_for(:contact_type).backed_by_column_of_type(:string)
    )
  end

  describe '#display_duration_minutes' do
    context 'when duration_minutes is less than 60' do
      it 'returns only minutes' do
        case_contact = create(:case_contact, duration_minutes: 30)

        expect(case_contact.display_duration_minutes).to eq '30 minutes'
      end
    end

    context 'when duration_minutes is greater than 60' do
      it 'returns minutes and hours' do
        case_contact = create(:case_contact, duration_minutes: 135)

        expect(case_contact.display_duration_minutes).to eq '2 hours 15 minutes'
      end
    end
  end
end
