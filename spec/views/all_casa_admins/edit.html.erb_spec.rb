# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'all_casa_admins/edit', type: :view do
  let(:user) { build_stubbed(:all_casa_admin) }

  before do
    assign(:user, user)
    render
  end

  it 'renders the edit profile form', :aggregate_failures do
    expect(rendered).to have_selector("form[action='#{all_casa_admins_path}'][method='post']")
    expect(rendered).to have_field('all_casa_admin[email]')
    expect(rendered).to have_button('Update Profile')
  end

  it 'renders the change password collapse section, hidden by default', :aggregate_failures do
    expect(rendered).to have_selector('#collapseOne.collapse')
    expect(rendered).not_to include('class="collapse show"')
    expect(rendered).to have_field('all_casa_admin[password]')
    expect(rendered).to have_field('all_casa_admin[password_confirmation]')
    expect(rendered).to have_button('Update Password')
  end

  context 'when there are error and flash messages' do
    before do
      user.errors.add(:email, "can't be blank")
      flash[:notice] = 'Profile updated'
      render
    end

    it 'renders error and flash messages partials', :aggregate_failures do
      expect(rendered).to have_selector('#error_explanation.alert')
      expect(rendered).to have_text("can't be blank")
      expect(rendered).to have_selector('.header-flash')
      expect(rendered).to have_text('Profile updated')
    end
  end

  context 'when submitting the password change form' do
    before do
      sign_in user
      assign(:user, user)
      render
    end

    it 'shows error when password fields are blank', :aggregate_failures do
      user.errors.add(:password, "can't be blank")
      render
      expect(rendered).to have_selector('#error_explanation.alert')
      expect(rendered).to have_text("can't be blank")
    end

    it 'shows error when password confirmation does not match', :aggregate_failures do
      user.errors.add(:password_confirmation, "doesn't match Password")
      render
      expect(rendered).to have_selector('#error_explanation.alert')
      expect(rendered).to have_text("doesn't match Password")
    end
  end
end
