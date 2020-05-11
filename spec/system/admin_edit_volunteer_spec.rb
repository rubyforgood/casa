require 'rails_helper'

RSpec.describe 'Admin: Editing Volunteers', type: :system do
  let(:admin) { create(:user, :casa_admin) }
  let(:volunteer) { create(:user, :volunteer) }

  it 'saves the user as inactive, but only if the admin confirms' do  
    sign_in admin
    visit edit_volunteer_path(volunteer)  

    choose "Inactive"

    dismiss_confirm do
      click_on "Submit"
    end
    volunteer.reload
    expect(volunteer).to be_is_active

    accept_confirm do
      click_on "Submit"
    end
    volunteer.reload
    expect(volunteer).not_to be_is_active
  end  
end
