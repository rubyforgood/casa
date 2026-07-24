/* global $ */

function convertDateToSystemTimeZone (date) {
  return new Date((typeof date === 'string' ? new Date(date) : date))
}

$(document).on('turbo:load', function () {
  $('.filter-form').on('change', '.filter-input', function () {
    $(this).closest('form').submit()
  })
})

$(() => {
  $('[data-toggle="tooltip"]').tooltip()
})

export {
  convertDateToSystemTimeZone
}
