/* global $, localStorage */
$('document').ready(() => {
  $('form#new_user').on('submit', function () {
    localStorage.clear()
  })
})
