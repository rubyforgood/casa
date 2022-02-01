/* eslint-env jest */

require('jest')


beforeEach(() => {
  const $ = require('jquery')
  document.body.innerHTML =
  '<style>' +
  '  #case_contact_additional_expenses_attributes_1_other_expense_amount { display: none; }' +
  '</style>' + 
  '<div>' +   
  ' <a href="#" class="add-another-expense" id="add-another-expense">Add another expense</a>' + 
  ' <input placeholder="Enter amount" class="form-control other-expense-amount hide-field" min="0" max="1000" step="0.01" type="number" name="case_contact[additional_expenses_attributes][1][other_expense_amount]" id="case_contact_additional_expenses_attributes_1_other_expense_amount">' + 
  ' <input placeholder="Describe the expense" class="form-control other-expenses-describe hide-field" type="text" name="case_contact[additional_expenses_attributes][1][other_expenses_describe]" id="case_contact_additional_expenses_attributes_1_other_expenses_describe">' + 
  '</div>'
  
  
  $(document).ready(() => {
    addAdditionalExpenseElement = $('#add-another-expense')
    addAdditionalExpense= new AddAdditionalExpense(addAdditionalExpenseElement)
  })
})

describe('Add Additional Expense tests', () => {
  test('Test link to add expenses is present', () => {
    expect($('#add-another-expense').text()).toEqual("Add another expense")
  })
  test('Test that initial expense amount field is hidden', () => {
    expect($('#case_contact_additional_expenses_attributes_1_other_expense_amount').is(':hidden')).toBe(true)
  })
  test('Test that initial expense describe field is hidden', () => {
    expect($('#case_contact_additional_expenses_attributes_1_other_expenses_describe').is(':hidden')).toBe(true)
  })
  test('Displays a new set of fields after a click', () => {
    
    require('../src/add_additional_expense')
    $('#add-additional-expense').click()

    expect($('#case_contact_additional_expenses_attributes_1_other_expense_amount').is(':visible')).toBe(true)
    
  })
})


/// the problem is that the link itself doesn't call the js

// expect($('#case_contact_additional_expenses_attributes_1_other_expense_amount')).toBeVisible();
// expect('Enter amount').toBeVisible();
// expect(getByText('Enter amount')).toBeInDocument();
// expect($('#case_contact_additional_expenses_attributes_1_other_expense_amount').is(':visible')).toBe(true)
// expect($('#case_contact_additional_expenses_attributes_1_other_expense_amount').text()).toEqual('Enter amount')