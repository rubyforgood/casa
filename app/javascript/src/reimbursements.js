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

  const formatCreatedAtDate = (inputDate) => {
    const date = new Date(inputDate)
    return date.toLocaleString('en-US', {
      month: 'long',
      day: '2-digit',
      year: 'numeric'
    })
  }

  const renderContactTypes = (contactTypes) => {
    if (!Array.isArray(contactTypes)) {
      return ''
    }

    return contactTypes.map((contactType) => {
      return `${contactType.group_name} (${contactType.name})`
    }).join(', ')
  }

  // Enable all data tables on dashboard but only filter on volunteers table
  const editVolunteerPath = id => `/volunteers/${id}/edit`
  const casaCasePath = id => `/casa_cases/${id}`
  const mobileLabel = title => `<span class="mobile-label">${title}</span>`
  $('table#reimbursements-table').DataTable({
    autoWidth: false,
    stateSave: false,
    order: [[3, 'desc']],
    columns: [
      {
        name: 'volunteer',
        render: (data, type, row, meta) => {
          return `
            ${mobileLabel('Volunteer')}
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
            ${mobileLabel('Case Number(s)')}
            <a href="${casaCasePath(row.casa_case.id)}">${row.casa_case.case_number}</a>
          `
        }
      },
      {
        name: 'contact_types',
        render: (data, type, row, meta) => {
          return `
            ${mobileLabel('Contact Type(s)')}
            ${renderContactTypes(row.contact_types)}
          `
        },
        orderable: false
      },
      {
        name: 'date_added',
        render: (data, type, row, meta) => {
          return `
            ${mobileLabel('Date Added')}
            ${formatCreatedAtDate(row.created_at)}
          `
        },
        searchable: false
      },
      {
        name: 'expense_type',
        render: (data, type, row, meta) => mobileLabel('Expense Type'),
        searchable: false,
        orderable: false
      },
      {
        name: 'description',
        render: (data, type, row, meta) => mobileLabel('Description'),
        orderable: false
      },
      {
        name: 'miles_driven',
        render: (data, type, row, meta) => {
          return `
            ${mobileLabel('Amount')}
            ${row.miles_driven}
          `
        },
        searchable: false
      },
      {
        name: 'reimbursement_complete',
        render: (data, type, row, meta) => {
          return `
            ${mobileLabel('Reimbursement Complete?')}
            TODO
          `
        },
        searchable: false,
        orderable: false
      }
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
})
