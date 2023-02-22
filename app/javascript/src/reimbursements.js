/* global $ */

$('document').ready(() => {
  const { groupBy, map, mapValues } = require('lodash')
  const strftime = require('strftime')

  const formatOccurredAtDate = (record) => new Date(Date.parse(record.occurred_at.replaceAll('-', ' '))).toDateString()

  const mapContactTypes = (contactTypes) => {
    return mapValues(
      groupBy(contactTypes, 'group_name'),
      contactType => map(contactType, 'name').join(', ')
    )
  }

  const renderContactTypes = (record) => {
    if (!record || !Array.isArray(record.contact_types)) {
      return ''
    }

    return map(
      mapContactTypes(record.contact_types),
      (names, groupName) => `${groupName} (${names})`
    ).join(', ')
  }

  const renderCompleteCheckbox = (record) => `
    <label>
      Yes
      <input
        ${record.complete === 'true' ? 'checked' : ''}
        name="case_contact[reimbursement_complete]"
        type="checkbox"
        data-submit-to="${record.mark_as_complete_path}"
      />
    </label>
  `

  const editVolunteerPath = id => `/volunteers/${id}/edit`
  const casaCasePath = id => `/casa_cases/${id}`

  const onMarkAsCompleteChange = (event) => {
    const $checkbox = $(event.target)

    try {
      const url = $checkbox.data('submit-to')
      const reimbursementComplete = $checkbox.is(':checked')

      if (!url) {
        throw new Error('URL missing')
      }

      $.ajax(url, {
        data: JSON.stringify({
          case_contact: {
            reimbursement_complete: reimbursementComplete
          },
          ajax: true
        }),
        method: 'PATCH',
        contentType: 'application/json'
      }).then(() => reimbursementsTable.draw())
    } catch (error) {
      console.log(error)
      event.target.checked = !event.target.checked
      window.alert('Failed to update reimbursement complete setting')
    }

    return false
  }

  $('table#reimbursements-datatable').on('draw.dt', function (e) {
    $(e.target)
      .find('input[name="case_contact[reimbursement_complete]"]')
      .on('change', onMarkAsCompleteChange)
  })

  $('[data-filter="volunteer"] .select2').on('select2:select select2:unselect', () => reimbursementsTable.draw())
  $('[data-filter="occurred_at"] input').on('change', () => reimbursementsTable.draw())

  const handleAjaxError = e => {
    if (e.status === 401) {
      window.location.reload()
    } else {
      console.log(e)
      if (e.responseJSON && e.responseJSON.error) {
        window.alert(e.responseJSON.error)
      } else {
        const responseErrorMessage = e.response.statusText
          ? `\n${e.response.statusText}\n`
          : ''

        window.alert(`Sorry, try that again?\n${responseErrorMessage}\nIf you're seeing a problem, please fill out the Report A Site Issue
        link to the bottom left near your email address.`)
      }
    }
  }

  const getDatatableFilterParams = () => {
    return {
      volunteers: selectedVolunteerIdsOrAll(),
      occurred_at: {
        start: $('input[name="occurred_at_starting"]').val(),
        end: $('input[name="occurred_at_ending"]').val()
      }
    }
  }

  const selectedVolunteerIdsOrAll = () => {
    let selectedVols = $('[data-filter="volunteer"] .creator_ids').val()
    if (selectedVols.length === 0) {
      selectedVols = map($('[data-filter="volunteer"] .creator_ids option'), 'value')
    }
    return selectedVols
  }

  const reimbursementsTableCols = [
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
      }
    },
    {
      name: 'contact_types',
      render: (data, type, row, meta) => {
        return `
          <span class="mobile-label">Contact Type(s)</span>
            ${renderContactTypes(row)}
          `
      },
      orderable: false
    },
    {
      name: 'occurred_at',
      render: (data, type, row, meta) => {
        return `
          <span class="mobile-label">Date Added</span>
          ${formatOccurredAtDate(row)}
        `
      }
    },
    {
      name: 'miles_driven',
      render: (data, type, row, meta) => {
        return `
          <span class="mobile-label">Expense Type</span>
          ${row.miles_driven}
        `
      }
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
          ${renderCompleteCheckbox(row)}
        `
      },
      orderable: false
    }
  ]

  const reimbursementsTable = $('table#reimbursements-datatable').DataTable({
    autoWidth: false,
    stateSave: false,
    order: [[3, 'desc']],
    searching: false,
    columns: reimbursementsTableCols,
    processing: true,
    serverSide: true,
    ajax: {
      url: $('table#reimbursements-datatable').data('source'),
      type: 'POST',
      data: function (data) {
        return $.extend({}, data, getDatatableFilterParams())
      },
      error: handleAjaxError,
      dataType: 'json'
    }
  })
})
