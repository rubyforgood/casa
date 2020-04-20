require 'rails_helper'

RSpec.describe CasaCasePolicy do
  subject { described_class }

  permissions :update_case_number? do
    context 'when user is an admin' do
      it 'returns true' do
        casa_case = create(:casa_case)
        admin = create(:user, :casa_admin)
        expect(Pundit.policy(admin, casa_case).update_case_number?).to eq true
      end
    end

    context 'when user is a volunteer' do
      it 'returns false' do
        casa_case = create(:casa_case)
        volunteer = create(:user, :volunteer)
        expect(Pundit.policy(volunteer, casa_case).update_case_number?).to eq false
      end
    end
  end
end
