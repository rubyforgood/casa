/* global $ */

$(() => { // JQuery's callback for the DOM loading
  if ($('table.admin-list').length > 0) {
    $('table.admin-list').DataTable({ searching: true, order: [[0, 'asc']] })
  }

  if ($('table.organization-list').length > 0) {
    $('table.organization-list').DataTable({ searching: true, order: [[0, 'asc']] })
  }
})
