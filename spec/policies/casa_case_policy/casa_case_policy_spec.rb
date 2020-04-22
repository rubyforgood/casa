require 'rails_helper'

RSpec.describe CasaCasePolicy do
  subject { described_class }

  permissions :update_case_number? do
    context 'when user is an admin' do
      it 'does allow update case number' do
        expect(subject).to permit(create(:user, :casa_admin), create(:casa_case))
      end
    end

    context 'when user is a volunteer' do
      it 'does not allow update case number' do
        expect(subject).not_to permit(create(:user, :volunteer), create(:casa_case))
      end
    end
  end

  permissions :show? do
    it 'allows casa_admins' do
      expect(subject).to permit(create(:user, :casa_admin), create(:casa_case))
    end

    context 'when volunteer is assigned' do
      it 'allows the volunteer' do
        volunteer = create(:user, :volunteer)
        casa_case = create(:casa_case)
        volunteer.casa_cases << casa_case
        expect(subject).to permit(volunteer, casa_case)
      end
    end

    context 'when volunteer is not assigned' do
      it 'does not allow the volunteer' do
        expect(subject).not_to permit(create(:user, :volunteer), create(:casa_case))
      end
    end
  end

  permissions :edit? do
    it 'allows casa_admins' do
      expect(subject).to permit(create(:user, :casa_admin), create(:casa_case))
    end

    context 'when volunteer is assigned' do
      it 'allows the volunteer' do
        volunteer = create(:user, :volunteer)
        casa_case = create(:casa_case)
        volunteer.casa_cases << casa_case
        expect(subject).to permit(volunteer, casa_case)
      end
    end

    context 'when volunteer is not assigned' do
      it 'does not allow the volunteer' do
        expect(subject).not_to permit(create(:user, :volunteer), create(:casa_case))
      end
    end
  end

  permissions :new? do
    it 'allows casa_admins' do
      expect(subject).to permit(create(:user, :casa_admin))
    end

    it 'does not allow volunteers' do
      expect(subject).not_to permit(create(:user, :volunteer))
    end
  end

  permissions :update? do
    it 'allows casa_admins' do
      expect(subject).to permit(create(:user, :casa_admin))
    end

    it 'does not allow volunteers' do
      expect(subject).not_to permit(create(:user, :volunteer))
    end
  end

  permissions :create? do
    it 'allows casa_admins' do
      expect(subject).to permit(create(:user, :casa_admin))
    end

    it 'does not allow volunteers' do
      expect(subject).not_to permit(create(:user, :volunteer))
    end
  end

  permissions :destroy? do
    it 'allows casa_admins' do
      expect(subject).to permit(create(:user, :casa_admin))
    end

    it 'does not allow volunteers' do
      expect(subject).not_to permit(create(:user, :volunteer))
    end
  end
end
