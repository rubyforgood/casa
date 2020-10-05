require 'rails_helper'

RSpec.describe 'admin adds a new case', type: :system do
  let(:admin) { create(:casa_admin) }
  let(:case_number) { '12345' }

  before do
    sign_in admin
    visit root_path
    click_on 'Cases'

    click_on 'New Case'
  end

  context 'when all fields are filled' do
    it 'is successful' do
      fill_in 'Case number', with: case_number 
      select '3', from: 'casa_case_court_date_3i'
      select 'March', from: 'casa_case_court_date_2i'
      select '2020', from: 'casa_case_court_date_1i'
  
      check 'Transition aged youth'
      has_checked_field? 'Transition aged youth'
  
      click_on 'Create CASA Case'

      expect(page.body).to have_content(case_number)
      expect(page).to have_content('CASA case was successfully created.')
      expect(page).to have_content('Next Court Date: Tuesday, 3-MAR-2020')
      expect(page).to have_content('Transition Aged Youth: Yes')
    end
  end

  context 'when non-mandatory fields are not filled' do
    it 'is successful' do
      fill_in 'Case number', with: case_number
      click_on 'Create CASA Case'

      expect(page.body).to have_content(case_number)
      expect(page).to have_content('CASA case was successfully created.')
      expect(page).to have_content('Next Court Date:')
      expect(page).to have_content('Transition Aged Youth: No')
    end
  end

  context 'when the case number field is not filled' do
    it 'does not create a new case' do
      click_on 'Create CASA Case'

      expect(current_path).to eq(casa_cases_path)
      expect(page).to have_content('Case number can\'t be blank')
    end
  end

  context 'when the case number already exists' do
    let!(:casa_case) { create(:casa_case, case_number: case_number) }
    
    it 'does not create a new case' do
      fill_in 'Case number', with: case_number
      click_on 'Create CASA Case'

      expect(current_path).to eq(casa_cases_path)
      expect(page).to have_content('Case number has already been taken')
    end
  end
end
