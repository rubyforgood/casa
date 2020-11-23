/* global $ */
var defineCaseContactsTable = function () {
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

      var statusArray = []
      var assignedToVolunteerArray = []
      var assignedToMoreThanOneVolunteerArray = []
      var assignedToTransitionYouthArray = []
      var caseNumberPrefixArray = []

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

      var status = data[3]
      var assignedToVolunteer = (data[5] !== '' && data[5].split(',').length >= 1) ? 'Yes' : 'No'
      var assignedToMoreThanOneVolunteer = (data[5] !== '' && data[5].split(',').length > 1) ? 'Yes' : 'No'
      var assignedToTransitionYouth = data[4]
      var regex = /^(CINA|TPR)/g
      var caseNumberPrefix = data[0].match(regex) ? data[0].match(regex)[0] : ''

      if (statusArray.includes(status) &&
        assignedToVolunteerArray.includes(assignedToVolunteer) &&
        assignedToMoreThanOneVolunteerArray.includes(assignedToMoreThanOneVolunteer) &&
        assignedToTransitionYouthArray.includes(assignedToTransitionYouth) &&
        caseNumberPrefixArray.includes(caseNumberPrefix)
      ) {
        return true
      }
      return false
    }
  )

  // Enable all data tables on dashboard but only filter on volunteers table
  var volunteersTable = $('table#volunteers').DataTable({
    autoWidth: false,
    stateSave: false,
    columns: [
      {
        data: "display_name"
      },
      {
        data: "email",
        visible: false
      },
      {
        className: "supervisor-column",
        data: "supervisor_name",
      },
      {
        data: "active",
        searchable: false,
      },
      {
        data: "has_transition_aged_youth_cases",
        searchable: false
      },
      {
        data: "case_numbers",
        orderable: false
      },
      {
        data: "most_recent_contact_occurred_at",
        searchable: false,
        visible: false
      },
      {
        data: "contacts_made_in_past_60_days",
        searchable: false,
        visible: false
      },
      {
        data: "actions",
        orderable: false,
        searchable: false
      }
    ],
    processing: true,
    serverSide: true,
    ajax: {
      url: $('table#volunteers').data('source'),
      type: "POST",
      data: function (d) {
        const supervisorOptions = $(".supervisor-options input:checked");
        const supervisorFilter = Array.from(supervisorOptions).map(option => option.dataset.value);

        const statusOptions = $(".status-options input:checked");
        const statusFilter = Array.from(statusOptions).map(option => JSON.parse(option.dataset.value));

        const transitionYouthOptions = $(".transition-youth-options input:checked");
        const transitionYouthFilter = Array.from(transitionYouthOptions).map(option => JSON.parse(option.dataset.value));

        return $.extend({}, d, {
          additional_filters: {
            supervisor: supervisorFilter,
            active: statusFilter,
            transition_aged_youth: transitionYouthFilter
          }
        });
      },
      dataType: 'json'
    }
  })

  // Because the table saves state, we have to check/uncheck modal inputs based on what
  // columns are visible
  volunteersTable.columns().every(function (index) {
    var columnVisible = this.visible()

    if (columnVisible) { $('#visibleColumns input[data-column="' + index + '"]').prop('checked', true) } else { $('#visibleColumns input[data-column="' + index + '"]').prop('checked', false) }
  })

  var casaCasesTable = $('table#casa-cases').DataTable({
    autoWidth: false,
    stateSave: false,
    columnDefs: [],
    language: {
      emptyTable: 'No active cases'
    }
  })

  casaCasesTable.columns().every(function (index) {
    var columnVisible = this.visible()

    if (columnVisible) {
      $('#visibleColumns input[data-column="' + index + '"]').prop('checked', true)
    } else {
      $('#visibleColumns input[data-column="' + index + '"]').prop('checked', false)
    }
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

  $('.casa-case-filters input[type="checkbox"]').on('click', function () {
    casaCasesTable.draw()
  })

  $('input.toggle-visibility').on('click', function (e) {
    // Get the column API object and toggle the visibility
    var column = volunteersTable.column($(this).attr('data-column'))
    column.visible(!column.visible())
    volunteersTable.columns.adjust().draw()

    var caseColumn = casaCasesTable.column($(this).attr('data-column'))
    caseColumn.visible(!caseColumn.visible())
    casaCasesTable.columns.adjust().draw()
  })
})

export { defineCaseContactsTable }
