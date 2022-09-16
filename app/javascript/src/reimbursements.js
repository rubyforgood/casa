/* global $ */

$('document').ready(() => {
  
  const { groupBy, map, mapValues } = require('lodash')
  const strftime = require('strftime')

  $('table#reimbursements').DataTable({
    scrollX: false,
    searching: false,
    autoWidth: false,
    columnDefs: [],
    language: {
      emptyTable: 'No reimbursements'
    }
  })

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

  const formatOccurredAtDate = (record) => strftime('%B %d %Y', new Date(record.occurred_at))

  const mapContactTypes = (contactTypes) => {
    return mapValues(
      groupBy(contactTypes, 'group_name'),
      contactType => map(contactType, 'name').join(', '),
    )
  }

  const renderContactTypes = (record) => {
    if(!record || !Array.isArray(record.contact_types)) {
      return ''
    }

    return map(
      mapContactTypes(record.contact_types),
      (names, groupName) => `${groupName} (${names})`
    ).join(', ')
  }

  const editVolunteerPath = id => `/volunteers/${id}/edit`
  const casaCasePath = id => `/casa_cases/${id}`
  const volunteersTable = $('table#reimbursements-datatable').DataTable({
    autoWidth: false,
    stateSave: false,
    order: [[6, 'desc']],
    columns: [
      {
        name: 'display_name',
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
              ${renderContactTypes(row)}
            `
        }
      },
      {
        name: 'occurred_at',
        render: (data, type, row, meta) => {
          return `
            <span class="mobile-label">Date Added</span>
            ${formatOccurredAtDate(row)}
          `
        },
        searchable: false
      },
      {
        name: 'miles_driven',
        render: (data, type, row, meta) => {
          return `
            <span class="mobile-label">Expense Type</span>
            ${row.miles_driven}
          `
        },
        searchable: false
      },
      {
        name: 'address',
        render: (data, type, row, meta) => {
          return `
            <span class="mobile-label">Description</span>
            ${row.volunteer.address}
          `
        },
        orderable: false
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
      url: $('table#reimbursements-datatable').data('source'),
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
