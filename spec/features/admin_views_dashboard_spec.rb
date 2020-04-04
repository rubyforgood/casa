require 'rails_helper'

RSpec.describe 'admin views dashboard', type: :feature do
  let(:admin) {
    create(:user, :casa_admin)
  }

  it 'can see volunteers' do
    volunteer = create(:user, :volunteer, :with_casa_case, email: 'casa@example.com')
    casa_case = volunteer.casa_cases[0]
    sign_in admin

    visit root_path

    expect(page).to have_text('casa@example.com')
    expect(page).to have_text(casa_case.case_number)
  end

  it 'can go to the volunteer edit page from the volunteer list' do
    volunteer = create(:user, :volunteer)
    sign_in admin

    visit root_path

    within "#volunteers" do
      click_on "Edit"
    end

    expect(page).to have_text("Editing Volunteer")
  end
end
