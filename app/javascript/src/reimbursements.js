/* global $ */
/* global location */
/* global alert */

$(function () {
  const handleAjaxError = e => {
    if (e.status === 401) {
      location.reload()
    } else {
      console.log(e)
      if (e.responseJSON && e.responseJSON.error) {
        alert(e.responseJSON.error)
      } else {
        const responseErrorMessage = e.response.statusText
          ? `\n${e.response.statusText}\n`
          : ''

        alert(`Sorry, try that again?\n${responseErrorMessage}\nIf you're seeing a problem, please fill out the Report A Site Issue
        link to the bottom left near your email address.`)
      }
    }
  }

  // Enable all data tables on dashboard but only filter on volunteers table
  const editVolunteerPath = id => `/volunteers/${id}/edit`
  const casaCasePath = id => `/casa_cases/${id}`
  const volunteersTable = $('table#reimbursements-table').DataTable({
    autoWidth: false,
    stateSave: false,
    order: [[6, 'desc']],
    columns: [
      {
        name: 'volunteer',
        render: (data, type, row, meta) => {
          return `
            <span class="mobile-label">Volunteer</span>
            <a href="${editVolunteerPath(row.volunteer.id)}">
              ${row.volunteer.display_name || row.volunteer.email}
            </a>
          `
        }
      },
      {
        name: 'case_number',
        render: (data, type, row, meta) => {
          return `
            <span class="mobile-label">Case Number(s)</span>
            <a href="${casaCasePath(row.casa_case.id)}">${row.casa_case.case_number}</a>
          `
        },
      },
      {
        name: 'contact_types',
        render: (data, type, row, meta) => {
          return `
            <span class="mobile-label">Contact Type(s)</span>
            TODO
          `
        }
      },
      {
        name: 'date_added',
        render: (data, type, row, meta) => {
          return `
            <span class="mobile-label">Date Added</span>
            TODO
          `
        },
        searchable: false
      },
      {
        name: 'expense_type',
        render: (data, type, row, meta) => {
          return `
            <span class="mobile-label">Expense Type</span>
            TODO
          `
        },
        searchable: false
      },
      {
        name: 'description',
        render: (data, type, row, meta) => {
          return `
            <span class="mobile-label">Description</span>
            TODO
          `
        },
        orderable: false
      },
      {
        name: 'amount',
        render: (data, type, row, meta) => {
          return `
            <span class="mobile-label">Amount</span>
            TODO
          `
        },
        searchable: false,
        visible: true
      },
      {
        name: 'reimbursement_complete',
        render: (data, type, row, meta) => {
          return `
            <span class="mobile-label">Reimbursement Complete?</span>
            TODO
          `
        },
        searchable: false,
      },
    ],
    processing: true,
    serverSide: true,
    ajax: {
      url: $('table#reimbursements-table').data('source'),
      type: 'POST',
      data: function (d) {
        return $.extend({}, d)
      },
      error: handleAjaxError,
      dataType: 'json'
    },
    drawCallback: function (settings) {
      $('[data-toggle=tooltip]').tooltip()
    }
  })

  console.log(volunteersTable)
});
