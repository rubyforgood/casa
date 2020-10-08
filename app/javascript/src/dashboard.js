/* global $ */
$('document').ready(() => {
  $.fn.dataTable.ext.search.push(
    function (settings, data, dataIndex) {
      if ($('#unassigned-vol-filter').is(':checked')) {
        var supervisorArray = ['']
      } else {
        var supervisorArray = []
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

  $('table#casa_cases').DataTable({ searching: false })
  $('table#case_contacts').DataTable({ searching: false, order: [[0, 'desc']] })

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

  $('input.toggle-visibility').on('click', function (e) {
    // Get the column API object and toggle the visibility
    var column = volunteersTable.column($(this).attr('data-column'))
    column.visible(!column.visible())
    volunteersTable.columns.adjust().draw()
  })
})
