/* global $ */

$(() => { // JQuery's callback for the DOM loading
  $('table#all-case-emancipations').DataTable({
    autoWidth: false,
    searching: false,
    stateSave: false,
    columnDefs: [
      { orderable: false, targets: 1 }
    ],
    language: {
      emptyTable: 'No transitioning cases'
    }
  })
})
