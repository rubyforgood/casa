/* eslint-env jest */

require('jest')

beforeEach(() => {
  const $ = require('jquery')
  document.body.innerHTML =
  '<div>' +
  ' <a href="#" class="add-another-expense" id="add-another-expense">Add another expense</a>' +
  '<div class="expense-container id="expense2" style="display:none">' +
  ' <input placeholder="Enter amount" class="form-control other-expenses-describe hide-field" type="text" name="case_contact[additional_expenses_attributes][1][other_expenses_describe]" id="case_contact_additional_expenses_attributes_1_other_expense_amount" style="display: inline-block;">' +
  ' <input placeholder="Describe the expense" class="form-control other-expenses-describe hide-field" type="text" name="case_contact[additional_expenses_attributes][1][other_expenses_describe]" id="case_contact_additional_expenses_attributes_1_other_expenses_describe" style="display: inline-block;" >' +
  '</div>' +
  '</div>'

  $(document).ready(() => {
  })
})

describe('Add Additional Expense tests', () => {
  test('Test link to add expenses is present', () => {
    expect($('#add-another-expense').text()).toEqual('Add another expense')
  })
  test('Test that initial additional expense is hidden', () => {
    expect($('#expense2').css('display: none'))
  })
  test('Displays the first additional expense after a click', () => {
    require('../src/add_additional_expense')

    $('#add-additional-expense').trigger('click')

    expect($('#expense2').css('display: flex'))
  })
})
