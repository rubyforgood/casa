require 'rails_helper'

RSpec.describe 'volunteer adds a case contact', type: :feature do
  it 'is successful' do
    volunteer = create(:user, :volunteer, :with_casa_cases)
    volunteer_casa_case_1 = volunteer.casa_cases.first

    sign_in volunteer

    visit new_case_contact_path

    select volunteer_casa_case_1.case_number, from: 'casa_case_id'
    select 'School', from: 'contact_type'
    select '60 minutes', from: 'duration_minutes'
    fill_in 'case_contact_occurred_at', with: '04/04/2020'

    click_on 'Submit'

    expect(CaseContact.first.casa_case_id).to eq volunteer_casa_case_1.id
    expect(CaseContact.first.contact_type).to eq 'school'
    expect(CaseContact.first.duration_minutes).to eq 60
  end

  it 'chooses other' do
    volunteer = create(:user, :volunteer, :with_casa_cases)
    volunteer_casa_case_1 = volunteer.casa_cases.first

    sign_in volunteer

    visit new_case_contact_path

    select volunteer_casa_case_1.case_number, from: 'casa_case_id'
    select 'School', from: 'contact_type'
    expect(page).not_to have_selector '#case_contact_other_type_text'
    select '90 minutes', from: 'duration_minutes'
    fill_in 'case_contact_occurred_at', with: '04/04/2020'
    select 'Other', from: 'contact_type'

    click_on 'Submit'

    expect(CaseContact.first.casa_case_id).to eq volunteer_casa_case_1.id
    expect(CaseContact.first.contact_type).to eq 'other'
    expect(CaseContact.first.other_type_text).to eq nil
    expect(CaseContact.first.duration_minutes).to eq 90
  end
end
