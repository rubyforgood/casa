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
      if (settings.nTable.id !== 'volunteers') {
        return true
      }
      var supervisorArray = []

      if ($('#unassigned-vol-filter').is(':checked')) {
        supervisorArray = ['']
      }

      var statusArray = []
      var assignedToTransitionYouthArray = []

      $('.supervisor-options').find('input[type="checkbox"]').each(function () {
        if ($(this).is(':checked')) {
          supervisorArray.push($(this).data('value'))
        }
      })

      $('.status-options').find('input[type="checkbox"]').each(function () {
        if ($(this).is(':checked')) {
          statusArray.push($(this).data('value'))
        }
      })

      $('.transition-youth-options').find('input[type="checkbox"]').each(function () {
        if ($(this).is(':checked')) {
          assignedToTransitionYouthArray.push($(this).data('value'))
        }
      })

      var supervisor = data[2]
      var status = data[3]
      var assignedToTransitionYouth = data[4]

      if (supervisorArray.includes(supervisor) &&
        statusArray.includes(status) &&
        assignedToTransitionYouthArray.includes(assignedToTransitionYouth)) {
        return true
      }
      return false
    }
  )

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
    columnDefs: [
      {
        targets: [1],
        visible: false
      },
      {
        targets: [6],
        visible: false
      },
      {
        targets: [7],
        visible: false
      }
    ]
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
