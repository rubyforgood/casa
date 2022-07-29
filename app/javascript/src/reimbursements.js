/* global $ */

$('document').ready(() => {
  $('table#reimbursements').DataTable({
    scrollX: false,
    searching: false,
    autoWidth: false,
    columnDefs: [],
    language: {
      emptyTable: 'No reimbursements'
    }
  })
})
