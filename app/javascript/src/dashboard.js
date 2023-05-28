/* global alert */
/* global $ */

const defineCaseContactsTable = function () {
  $('table#case_contacts').DataTable(
    {
      scrollX: true,
      searching: false,
      order: [[0, 'desc']]
    }
  )
}

$('document').ready(() => {
  $.fn.dataTable.ext.search.push(
    function (settings, data, dataIndex) {
      if (settings.nTable.id !== 'casa-cases') {
        return true
      }

      const statusArray = []
      const assignedToVolunteerArray = []
      const assignedToMoreThanOneVolunteerArray = []
      const assignedToTransitionYouthArray = []
      const caseNumberPrefixArray = []

      $('.status-options').find('input[type="checkbox"]').each(function () {
        if ($(this).is(':checked')) {
          statusArray.push($(this).data('value'))
        }
      })

      $('.assigned-to-volunteer-options').find('input[type="checkbox"]').each(function () {
        if ($(this).is(':checked')) {
          assignedToVolunteerArray.push($(this).data('value'))
        }
      })

      $('.more-than-one-volunteer-options').find('input[type="checkbox"]').each(function () {
        if ($(this).is(':checked')) {
          assignedToMoreThanOneVolunteerArray.push($(this).data('value'))
        }
      })

      $('.transition-youth-options').find('input[type="checkbox"]').each(function () {
        if ($(this).is(':checked')) {
          assignedToTransitionYouthArray.push($(this).data('value'))
        }
      })

      $('.case-number-prefix-options').find('input[type="checkbox"]').each(function () {
        if ($(this).is(':checked')) {
          caseNumberPrefixArray.push($(this).data('value'))
        }
      })

      const possibleCaseNumberPrefixes = ['CINA', 'TPR']
      const status = data[3]
      const assignedToVolunteer = (data[5] !== '' && data[5].split(',').length >= 1) ? 'Yes' : 'No'
      const assignedToMoreThanOneVolunteer = (data[5] !== '' && data[5].split(',').length > 1) ? 'Yes' : 'No'
      const assignedToTransitionYouth = data[4]
      const caseNumberPrefix = possibleCaseNumberPrefixes.includes(data[0].split('-')[0]) ? data[0].split('-')[0] : 'None'

      return statusArray.includes(status) &&
        assignedToVolunteerArray.includes(assignedToVolunteer) &&
        assignedToMoreThanOneVolunteerArray.includes(assignedToMoreThanOneVolunteer) &&
        assignedToTransitionYouthArray.includes(assignedToTransitionYouth) &&
        caseNumberPrefixArray.includes(caseNumberPrefix)
    }
  )

  const handleAjaxError = e => {
    console.error(e)
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

  // Enable all data tables on dashboard but only filter on volunteers table
  const editSupervisorPath = id => `/supervisors/${id}/edit`
  const editVolunteerPath = id => `/volunteers/${id}/edit`
  const impersonateVolunteerPath = id => `/volunteers/${id}/impersonate`
  const casaCasePath = id => `/casa_cases/${id}`
  const volunteersTable = $('table#volunteers').DataTable({
    autoWidth: false,
    stateSave: true,
    initComplete: function (settings, json) {
      this.api().columns().every(function (index) {
        const columnVisible = this.visible()
        $('#visibleColumns input[data-column="' + index + '"]').prop('checked', columnVisible)
      })
    },
    stateSaveCallback: function (settings, data) {
      $.ajax({
        url: '/preference_sets/table_state_update/' + settings.nTable.id + '_table',

        data: {
          table_state: JSON.stringify(data)
        },
        dataType: 'json',
        type: 'POST',
        success: function (response) { }
      })
    },
    stateSaveParams: function (settings, data) {
      data.search.search = ''
      return data
    },
    stateLoadCallback: function (settings, callback) {
      $.ajax({
        url: '/preference_sets/table_state/' + settings.nTable.id + '_table',
        dataType: 'json',
        type: 'GET',
        success: function (json) {
          callback(json)
        }
      })
    },
    order: [[6, 'desc']],
    columns: [
      {
        name: 'display_name',
        render: (data, type, row, meta) => {
          return `
            <span class="mobile-label">Name</span>
            <a href="${editVolunteerPath(row.id)}">
              ${row.display_name || row.email}
            </a>
          `
        }
      },
      {
        name: 'email',
        render: (data, type, row, meta) => row.email
      },
      {
        className: 'supervisor-column',
        name: 'supervisor_name',
        render: (data, type, row, meta) => {
          return row.supervisor.id
            ? `
            <span class="mobile-label">Supervisor</span>
              <a href="${editSupervisorPath(row.supervisor.id)}">
                ${row.supervisor.name}
              </a>
            `
            : ''
        }
      },
      {
        name: 'active',
        render: (data, type, row, meta) => {
          return `
            <span class="mobile-label">Status</span>
            ${row.active === 'true' ? 'Active' : 'Inactive'}
          `
        },
        searchable: false
      },
      {
        name: 'has_transition_aged_youth_cases',
        render: (data, type, row, meta) => {
          return `
          <span class="mobile-label">Assigned to Transitioned Aged Youth</span>
          ${row.has_transition_aged_youth_cases === 'true' ? 'Yes 🦋' : 'No 🐛'}`
        },
        searchable: false
      },
      {
        name: 'casa_cases',
        render: (data, type, row, meta) => {
          const links = row.casa_cases.map(casaCase => {
            return `
            <a href="${casaCasePath(casaCase.id)}">${casaCase.case_number}</a>
            `
          })
          const caseNumbers = `
            <span class="mobile-label">Case Number(s)</span>
            ${links.join(', ')}
          `
          return caseNumbers
        },
        orderable: false
      },
      {
        name: 'most_recent_attempt_occurred_at',
        render: (data, type, row, meta) => {
          return row.most_recent_attempt.case_id
            ? `
              <span class="mobile-label">Last Attempted Contact</span>
              <a href="${casaCasePath(row.most_recent_attempt.case_id)}">
                ${row.most_recent_attempt.occurred_at}
              </a>
            `
            : 'None ❌'
        },
        searchable: false
      },
      {
        name: 'contacts_made_in_past_days',
        render: (data, type, row, meta) => {
          return `
          <span class="mobile-label">Contacts</span>
          ${row.contacts_made_in_past_days}
          `
        },
        searchable: false
      },
      {
        name: 'hours_spent_in_days',
        render: (data, type, row, meta) => {
          return `
            <span class="mobile-label">Hours spent in last 30 days</span>
            ${row.hours_spent_in_days}
          `
        },
        searchable: false
      },
      {
        name: 'has_any_extra_languages ',
        render: (data, type, row, meta) => {
          const languages = row.extra_languages.map(x => x.name).join(', ')
          return row.extra_languages.length > 0 ? `<span class="language-icon" data-toggle="tooltip" title="${languages}">🌎</span>` : ''
        },
        searchable: false
      },
      {
        name: 'actions',
        orderable: false,
        render: (data, type, row, meta) => {
          return `
          <span class="mobile-label">Actions</span>
            <a href="${editVolunteerPath(row.id)}" class="btn btn-primary">
              Edit
            </a>
            <a href="${impersonateVolunteerPath(row.id)}" class="btn btn-secondary">
              Impersonate
            </a>
          `
        },
        searchable: false
      }
    ],
    processing: true,
    serverSide: true,
    ajax: {
      url: $('table#volunteers').data('source'),
      type: 'POST',
      data: function (d) {
        const supervisorOptions = $('.supervisor-options input:checked')
        const supervisorFilter = Array.from(supervisorOptions).map(option => option.dataset.value)

        const statusOptions = $('.status-options input:checked')
        const statusFilter = Array.from(statusOptions).map(option => JSON.parse(option.dataset.value))

        const transitionYouthOptions = $('.transition-youth-options input:checked')
        const transitionYouthFilter = Array.from(transitionYouthOptions).map(option => JSON.parse(option.dataset.value))

        const extraLanguageOptions = $('.extra-language-options input:checked')
        const extraLanguageFilter = Array.from(extraLanguageOptions).map(option => JSON.parse(option.dataset.value))
        return $.extend({}, d, {
          additional_filters: {
            supervisor: supervisorFilter,
            active: statusFilter,
            transition_aged_youth: transitionYouthFilter,
            extra_languages: extraLanguageFilter
          }
        })
      },
      error: handleAjaxError,
      dataType: 'json'
    },
    drawCallback: function (settings) {
      $('[data-toggle=tooltip]').tooltip()
    }
  })

  // Because the table saves state, we have to check/uncheck modal inputs based on what
  // columns are visible
  volunteersTable.columns().every(function (index) {
    const columnVisible = this.visible()
    $('#visibleColumns input[data-column="' + index + '"]').prop('checked', columnVisible)
    return true
  })

  // Add Supervisors Table
  const supervisorsTable = $('table#supervisors').DataTable({
    autoWidth: false,
    stateSave: false,
    order: [[1, 'asc']], // order by cast contacts
    columns: [
      {
        name: 'display_name',
        className: 'min-width',
        render: (data, type, row, meta) => {
          return `
            <a href="${editSupervisorPath(row.id)}">
              ${row.display_name || row.email}
            </a>
          `
        }
      },
      {
        name: '',
        className: 'min-width',
        render: (data, type, row, meta) => {
          const noContactVolunteers = Number(row.no_attempt_for_two_weeks)
          const transitionAgedCaseVolunteers = Number(row.transitions_volunteers)
          const activeContactVolunteers = Number(row.volunteer_assignments) - noContactVolunteers
          const activeContactElement = activeContactVolunteers
            ? (
            `
            <span class="attempted-contact status-btn success-bg text-white pl-${activeContactVolunteers * 15} pr-${activeContactVolunteers * 15}">
              ${activeContactVolunteers}
            </span>
            `
              )
            : ''

          const noContactElement = noContactVolunteers > 0
            ? (
            `
            <span class="no-attempted-contact status-btn danger-bg text-white pl-${noContactVolunteers * 15} pr-${noContactVolunteers * 15}">
              ${noContactVolunteers}
            </span>
            `
              )
            : ''

          let volunteersCounterElement = ''
          if (activeContactVolunteers <= 0 && noContactVolunteers <= 0) {
            volunteersCounterElement = '<span class="no-volunteers" style="flex-grow: 1">No assigned volunteers</span>'
          } else {
            volunteersCounterElement = `<span class="status-btn deactive-bg text-black pl-${transitionAgedCaseVolunteers * 15} pr-${transitionAgedCaseVolunteers * 15}">${transitionAgedCaseVolunteers}</span>`
          }

          return `
            <div class="supervisor_case_contact_stats">
              ${activeContactElement + noContactElement + volunteersCounterElement}
            </div>
          `
        }
      },
      {
        name: 'actions',
        orderable: false,
        render: (data, type, row, meta) => {
          return `
            <a href="${editSupervisorPath(row.id)}">
              <div class="action">
                <button class="text-danger">
                 <i class="lni lni-pencil-alt"></i>Edit
                </button>
              </div>
            </a>
          `
        },
        searchable: false
      }
    ],
    processing: true,
    serverSide: true,
    ajax: {
      url: $('table#supervisors').data('source'),
      type: 'POST',
      data: function (d) {
        const statusOptions = $('.status-options input:checked')
        const statusFilter = Array.from(statusOptions).map(option => JSON.parse(option.dataset.value))

        return $.extend({}, d, {
          additional_filters: {
            active: statusFilter
          }
        })
      },
      error: handleAjaxError,
      dataType: 'json'
    },
    drawCallback: function (settings) {
      $('[data-toggle=tooltip]').tooltip()
    },
    createdRow: function (row, data, dataIndex, cells) {
      row.setAttribute('id', `supervisor-${data.id}-information`)
    }
  })

  const casaCasesTable = $('table#casa-cases').DataTable({
    autoWidth: false,
    stateSave: false,
    columnDefs: [],
    language: {
      emptyTable: 'No active cases'
    }
  })

  casaCasesTable.columns().every(function (index) {
    const columnVisible = this.visible()

    if (columnVisible) {
      $('#visibleColumns input[data-column="' + index + '"]').prop('checked', true)
    } else {
      $('#visibleColumns input[data-column="' + index + '"]').prop('checked', false)
    }

    return true
  })

  defineCaseContactsTable()

  function filterOutUnassignedVolunteers (checked) {
    $('.supervisor-options').find('input[type="checkbox"]').not('#unassigned-vol-filter').each(function () {
      this.checked = checked
    })
  }

  $('#unassigned-vol-filter').on('click', function () {
    if ($('#unassigned-vol-filter').is(':checked')) {
      filterOutUnassignedVolunteers(false)
    } else {
      filterOutUnassignedVolunteers(true)
    }
    volunteersTable.draw()
  })

  $('.volunteer-filters input[type="checkbox"]').not('#unassigned-vol-filter').on('click', function () {
    volunteersTable.draw()
  })

  $('.supervisor-filters input[type="checkbox"]').on('click', function () {
    supervisorsTable.draw()
  })

  $('.casa-case-filters input[type="checkbox"]').on('click', function () {
    casaCasesTable.draw()
  })

  $('input.toggle-visibility').on('click', function (e) {
    // Get the column API object and toggle the visibility
    const column = volunteersTable.column($(this).attr('data-column'))
    column.visible(!column.visible())
    volunteersTable.columns.adjust().draw()

    const caseColumn = casaCasesTable.column($(this).attr('data-column'))
    caseColumn.visible(!caseColumn.visible())
    casaCasesTable.columns.adjust().draw()
  })
})

export { defineCaseContactsTable }
