require 'rails_helper'

RSpec.describe 'admin views dashboard', type: :feature do
  it 'can see volunteers' do
    admin = create(:user, :casa_admin)
    volunteer = create(:user, :volunteer, :with_casa_case, email: 'casa@example.com')
    casa_case = volunteer.casa_cases[0]
    sign_in admin
    login_as admin

    visit root_path

    expect(page).to have_text('casa@example.com')
    expect(page).to have_text(casa_case.case_number)
  end
end
