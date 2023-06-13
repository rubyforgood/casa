/* global $ */

function showAdditionalExpense () {
  for (let i = 1; i < 10; i++) {
    if ($(`#expense${i + 1}`).is(':hidden')) {
      $(`#expense${i + 1}`).wrap('<li></li>')
      $(`#expense${i + 1}`).removeClass('hide-field')
      break
    }
  }
}

$(document).on('click', '#add-another-expense', function () {
  showAdditionalExpense()
})
