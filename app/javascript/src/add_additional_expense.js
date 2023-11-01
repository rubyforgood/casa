/* global $ */

function showAdditionalExpense () {
  $('.expense-container.d-none').first().removeClass('d-none')
}

$(() => { // JQuery's callback for the DOM loading
  $('#add-another-expense').on('click', function () {
    showAdditionalExpense()
  })
})
