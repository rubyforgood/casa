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

  describe '#contact_made' do
    context 'when contact_made is false' do
      it 'returns No' do
        case_contact = create(:case_contact, contact_made: false)

        expect(case_contact.decorate.contact_made).to eq 'No'
      end
    end

    context 'when contact_made is true' do
      it 'returns Yes' do
        case_contact = create(:case_contact, contact_made: true)

        expect(case_contact.decorate.contact_made).to eq 'Yes'
      end
    end
  end

  describe '#medium_type' do
    context 'when medium_type is nil' do
      it 'returns Unknown' do
        case_contact = create(:case_contact, medium_type: nil)

        expect(case_contact.decorate.medium_type).to eq 'Unknown'
      end
    end

    context 'when medium_type is not nil' do
      it 'returns the titleized medium_type' do
        case_contact = create(:case_contact, medium_type: 'in-person')

        expect(case_contact.decorate.medium_type).to eq 'In Person'
      end
    end
  end
end
