require 'rails_helper'

RSpec.describe CaseContactDecorator do
  describe '#duration_minutes' do
    context 'when duration_minutes is less than 60' do
      it 'returns only minutes' do
        case_contact = create(:case_contact, duration_minutes: 30)

        expect(case_contact.decorate.duration_minutes).to eq '30 minutes'
      end
    end

    context 'when duration_minutes is greater than 60' do
      it 'returns minutes and hours' do
        case_contact = create(:case_contact, duration_minutes: 135)

        expect(case_contact.decorate.duration_minutes).to eq '2 hours 15 minutes'
      end
    end
  end
end
