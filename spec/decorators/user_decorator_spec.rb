require 'rails_helper'

RSpec.describe UserDecorator do
  describe '#status' do
    context 'when volunteer role is inactive' do
      it 'returns Inactive' do
        volunteer = create(:user, role: 'inactive')

        expect(volunteer.decorate.status).to eq 'Inactive'
      end
    end

    context 'when duration_minutes is greater than 60' do
      it 'returns Active' do
        volunteer = create(:user, role: 'volunteer')

        expect(volunteer.decorate.status).to eq 'Active'
      end
    end
  end
end
