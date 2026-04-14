/* global alert */
/* global $ */
import Swal from 'sweetalert2'
import { fireSwalFollowupAlert } from './case_contact'
const { Notifier } = require('./notifier')
let pageNotifier

const MAX_VISIBLE_TOPIC_PILLS = 2

function buildTopicPills (topics) {
  if (!topics || topics.length === 0) return ''
  const visible = topics.slice(0, MAX_VISIBLE_TOPIC_PILLS)
  const overflowCount = topics.length - visible.length
  const pills = visible
    .map(topic => `<span class="badge badge-pill light-bg text-black">${topic}</span>`)
    .join(' ')
  const overflowPill = overflowCount > 0
    ? ` <span class="badge badge-pill light-bg text-black">+${overflowCount} More</span>`
    : ''
  return pills + overflowPill
}

function buildExpandedContent (data) {
  const answers = (data.contact_topic_answers || [])
    .map(answer => `<div class="expanded-topic"><strong>${answer.question}</strong><p>${answer.value}</p></div>`)
    .join('')

  const notes = data.notes && data.notes.trim()
    ? `<div class="expanded-topic"><strong>Additional Notes</strong><p>${data.notes}</p></div>`
    : ''

  if (!answers && !notes) return '<p class="expanded-empty">No additional details.</p>'

  return `<div class="expanded-content">${answers}${notes}</div>`
}

const defineCaseContactsTable = function () {
  const table = $('table#case_contacts').DataTable({
    scrollX: true,
    searching: true,
    processing: true,
    serverSide: true,
    order: [[2, 'desc']], // Sort by Date column (index 2, after bell and chevron)
    ajax: {
      url: $('table#case_contacts').data('source'),
      type: 'POST',
      error: function (xhr, error, code) {
        console.error('DataTable error:', error, code)
      },
      dataType: 'json'
    },
    columnDefs: [
      { orderable: false, targets: [0, 1, 10] } // Bell, Chevron, and Ellipsis columns not orderable
    ],
    columns: [
      { // Bell icon column (index 0)
        data: 'has_followup',
        orderable: false,
        searchable: false,
        render: (data, type, row) => {
          return data === 'true'
            ? '<i class="fas fa-bell"></i>'
            : '<i class="fas fa-bell" style="opacity: 0.3;"></i>'
        }
      },
      { // Chevron icon column (index 1)
        data: null,
        orderable: false,
        searchable: false,
        render: () => '<button type="button" class="expand-toggle" aria-expanded="false" aria-label="Expand row details"><i class="fa-solid fa-chevron-down" aria-hidden="true"></i></button>'
      },
      { // Date column (index 2)
        data: 'occurred_at',
        name: 'occurred_at',
        render: (data) => data || ''
      },
      { // Case column (index 3)
        data: 'casa_case',
        orderable: false,
        render: (data) => {
          if (!data || !data.id) return ''
          const a = document.createElement('a')
          a.href = `/casa_cases/${data.id}`
          a.textContent = data.case_number
          return a.outerHTML
        }
      },
      { // Relationship (Contact Types) column (index 4)
        data: 'contact_types',
        orderable: false,
        render: (data) => data || ''
      },
      { // Medium column (index 5)
        data: 'medium_type',
        render: (data) => data || ''
      },
      { // Created By column (index 6)
        data: 'creator',
        orderable: false,
        render: (data) => {
          if (!data) return ''

          // Build edit link based on role
          let editPath = ''
          if (data.role === 'Supervisor') {
            editPath = `/supervisors/${data.id}/edit`
          } else if (data.role === 'Casa Admin') {
            editPath = '/users/edit'
          } else {
            editPath = `/volunteers/${data.id}/edit`
          }

          return $('<a>')
            .attr('href', editPath)
            .attr('data-turbo', 'false')
            .text(data.display_name)
            .prop('outerHTML')
        }
      },
      { // Contacted column (index 7)
        data: 'contact_made',
        orderable: false,
        render: (data, type, row) => {
          const icon = data === 'true'
            ? '<i class="lni lni-checkmark-circle" style="color: green;"></i>'
            : '<i class="lni lni-cross-circle" style="color: orange;"></i>'

          let duration = ''
          if (row.duration_minutes) {
            const hours = Math.floor(row.duration_minutes / 60)
            const minutes = row.duration_minutes % 60
            duration = ` (${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')})`
          }
          return icon + duration
        }
      },
      { // Topics column (index 8)
        data: 'contact_topics',
        orderable: false,
        render: (data) => buildTopicPills(data)
      },
      { // Draft column (index 9)
        data: 'is_draft',
        orderable: false,
        render: (data) => {
          return (data === true || data === 'true')
            ? '<span class="badge badge-pill light-bg text-black" data-testid="draft-badge">Draft</span>'
            : ''
        }
      },
      { // Ellipsis menu column (index 10)
        data: null,
        orderable: false,
        searchable: false,
        render: (_data, _type, row) => {
          const buttonId = `cc-actions-btn-${row.id}`
          const label = `Actions for case contact${row.occurred_at ? ' on ' + row.occurred_at : ''}`

          const editItem = row.can_edit === 'true'
            ? `<li role="none"><a class="dropdown-item" role="menuitem" href="${row.edit_path}" data-turbo="false">Edit</a></li>`
            : '<li role="none"><span class="dropdown-item disabled" role="menuitem" aria-disabled="true">Edit</span></li>'

          const deleteItem = row.can_destroy === 'true'
            ? `<li role="none"><button class="dropdown-item cc-delete-action" role="menuitem" type="button" data-id="${row.id}">Delete</button></li>`
            : '<li role="none"><button class="dropdown-item disabled" role="menuitem" type="button" disabled aria-disabled="true">Delete</button></li>'

          const reminderItem = row.followup_id
            ? `<li role="none"><button class="dropdown-item cc-resolve-reminder-action" role="menuitem" type="button" data-id="${row.id}" data-followup-id="${row.followup_id}">Resolve Reminder</button></li>`
            : `<li role="none"><button class="dropdown-item cc-set-reminder-action" role="menuitem" type="button" data-id="${row.id}">Set Reminder</button></li>`

          return `
            <div class="dropdown">
              <button type="button"
                      id="${buttonId}"
                      class="btn btn-link cc-ellipsis-toggle p-0"
                      data-bs-toggle="dropdown"
                      aria-haspopup="true"
                      aria-expanded="false"
                      aria-label="${label}">
                <i class="fas fa-ellipsis-v" aria-hidden="true"></i>
              </button>
              <ul class="dropdown-menu dropdown-menu-end"
                  role="menu"
                  aria-labelledby="${buttonId}">
                ${editItem}
                ${deleteItem}
                ${reminderItem}
              </ul>
            </div>
          `
        }
      }
    ]
  })

  $('table#case_contacts tbody').on('click', '.expand-toggle', function () {
    const tr = $(this).closest('tr')
    const row = table.row(tr)

    if (row.child.isShown()) {
      row.child.hide()
      $(this).removeClass('expanded').attr('aria-expanded', 'false')
    } else {
      row.child(buildExpandedContent(row.data())).show()
      $(this).addClass('expanded').attr('aria-expanded', 'true')
    }
  })

  const csrfToken = () => $('meta[name="csrf-token"]').attr('content')

  $('table#case_contacts').on('click', '.cc-delete-action', async function () {
    const id = $(this).data('id')
    const { isConfirmed } = await Swal.fire({
      title: 'Delete this contact?',
      showCancelButton: true,
      confirmButtonText: 'Delete',
      confirmButtonColor: '#dc3545'
    })
    if (!isConfirmed) return
    $.ajax({
      url: `/case_contacts/${id}`,
      type: 'DELETE',
      headers: { 'X-CSRF-Token': csrfToken() },
      success: () => table.ajax.reload()
    })
  })

  $('table#case_contacts').on('click', '.cc-set-reminder-action', async function () {
    const id = $(this).data('id')
    const { value: text, isConfirmed } = await fireSwalFollowupAlert()
    if (!isConfirmed) return
    const params = text ? { note: text } : {}
    $.ajax({
      url: `/case_contacts/${id}/followups`,
      type: 'POST',
      data: params,
      headers: { 'X-CSRF-Token': csrfToken() },
      success: () => table.ajax.reload()
    })
  })

  $('table#case_contacts').on('click', '.cc-resolve-reminder-action', function () {
    const followupId = $(this).data('followup-id')
    $.ajax({
      url: `/followups/${followupId}/resolve`,
      type: 'PATCH',
      headers: { 'X-CSRF-Token': csrfToken() },
      success: () => table.ajax.reload()
    })
  })
}

$(() => { // JQuery's callback for the DOM loading
  const notificationsElement = $('#notifications')

  if (notificationsElement.length && ($('table#case_contacts').length || $('table#casa_cases').length || $('table#volunteers').length || $('table#supervisors').length)) {
    pageNotifier = new Notifier(notificationsElement)
  }

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
        assignedToTransitionYouthArray.some(filterValue =>
          assignedToTransitionYouth.toLowerCase().includes(filterValue.toLowerCase().replace(/[^a-zA-Z]/g, ''))
        ) &&
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
        return $('#visibleColumns input[data-column="' + index + '"]').prop('checked', columnVisible)
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
        error: function (jqXHR, textStatus, errorMessage) {
          console.error(errorMessage)
          pageNotifier.notify('Error while saving preferences', 'error')
        }
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
    order: [[7, 'desc']],
    columns: [
      {
        data: 'id',
        targets: 0,
        searchable: false,
        orderable: false,
        render: (data, type, row, meta) => {
          return `
            <input type="checkbox" name="supervisor_volunteer[volunteer_ids][]" id="supervisor_volunteer_volunteer_ids_${row.id}" value="${row.id}" class="form-check-input" data-select-all-target="checkbox" data-action="select-all#toggleSingle">
          `
        }
      },
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
            <a href="${editVolunteerPath(row.id)}" class="btn btn-primary text-white">
              Edit
            </a>
            <a href="${impersonateVolunteerPath(row.id)}" class="btn btn-secondary text-white">
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
            <span class="attempted-contact supervisor-stat success-bg text-white pl-${activeContactVolunteers * 15} pr-${activeContactVolunteers * 15}" title="Number of Volunteers attempting contact (within 2 weeks)">
              ${activeContactVolunteers}
            </span>
            `
              )
            : ''

          const noContactElement = noContactVolunteers > 0
            ? (
            `
            <span class="no-attempted-contact supervisor-stat danger-bg text-white pl-${noContactVolunteers * 15} pr-${noContactVolunteers * 15}" title="Number of Volunteers not attempting contact (within 2 weeks)">
              ${noContactVolunteers}
            </span>
            `
              )
            : ''

          let volunteersCounterElement = ''
          if (activeContactVolunteers <= 0 && noContactVolunteers <= 0) {
            volunteersCounterElement = '<span class="no-volunteers" style="flex-grow: 1">No assigned volunteers</span>'
          } else {
            volunteersCounterElement = `<span class="supervisor-stat deactive-bg text-black pl-${transitionAgedCaseVolunteers * 15} pr-${transitionAgedCaseVolunteers * 15}" title="Count of Transition Aged Youth">${transitionAgedCaseVolunteers}</span>`
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
