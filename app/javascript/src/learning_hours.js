/* global $ */

$(() => { // JQuery's callback for the DOM loading
  if ($('table#learning-hours').length > 0) {
    $('table#learning-hours').DataTable({ searching: true, order: [[0, 'asc']] })
  }
})
