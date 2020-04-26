require 'rails_helper'

RSpec.describe 'volunteer adds a case contact', type: :feature do
  it 'is successful' do
    volunteer = create(:user, :volunteer, :with_casa_cases)
    volunteer_casa_case_one = volunteer.casa_cases.first

    sign_in volunteer

    visit new_case_contact_path

    find(:css, "input.casa-case-id-check[value='#{volunteer_casa_case_one.id}']").set(true)
    select 'School', from: 'case_contact[contact_type]'
    select '1 hour', from: 'case_contact[duration_hours]'
    select '45 minutes', from: 'case_contact[duration_minutes]'
    fill_in 'case_contact_occurred_at', with: '04/04/2020'

    click_on 'Submit'

    expect(CaseContact.first.casa_case_id).to eq volunteer_casa_case_one.id
    expect(CaseContact.first.contact_type).to eq 'school'
    expect(CaseContact.first.duration_minutes).to eq 105
  end

  it 'chooses other' do
    volunteer = create(:user, :volunteer, :with_casa_cases)
    volunteer_casa_case_one = volunteer.casa_cases.first

    sign_in volunteer

    visit new_case_contact_path

    find(:css, "input.casa-case-id-check[value='#{volunteer_casa_case_one.id}']").set(true)
    select 'School', from: 'case_contact[contact_type]'
    select '3 hours', from: 'case_contact[duration_hours]'
    select '15 minutes', from: 'case_contact[duration_minutes]'
    fill_in 'case_contact_occurred_at', with: '04/04/2020'
    select 'Other', from: 'case_contact[contact_type]'

    click_on 'Submit'

    expect(CaseContact.first.casa_case_id).to eq volunteer_casa_case_one.id
    expect(CaseContact.first.contact_type).to eq 'other'
    expect(CaseContact.first.other_type_text).to eq ''
    expect(CaseContact.first.duration_minutes).to eq 195
  end
end
