$('document').ready(() => {
  $.fn.dataTable.ext.search.push(
    function( settings, data, dataIndex ) {
      var supervisor_array = [""];
      var status_array = [];
      var assigned_to_transition_youth_array = [];

      $('.supervisor-options').find('input[type="checkbox"]').each(function() {
        if($(this).is(':checked')) {
          supervisor_array.push($(this).data('value'));
        }
      });

      $('.status-options').find('input[type="checkbox"]').each(function() {
        if($(this).is(':checked')) {
          status_array.push($(this).data('value'));
        }
      });

      $('.transition-youth-options').find('input[type="checkbox"]').each(function() {
        if($(this).is(':checked')) {
          assigned_to_transition_youth_array.push($(this).data('value'));
        }
      });

      var supervisor = data[2];
      var status = data[3];
      var assigned_to_transition_youth = data[4];

      if(supervisor_array.includes(supervisor) &&
        status_array.includes(status) &&
        assigned_to_transition_youth_array.includes(assigned_to_transition_youth)) {
        return true;
      }

      return false;
    }
  );

  // Enable all data tables on dashboard but only filter on volunteers table
  var volunteers_table = $('table#volunteers').DataTable({
    "autoWidth": false,
    "stateSave": true,
    "columnDefs": [
      {
        "targets": [1],
        "visible": false,
      },
      {
        "targets": [6],
        "visible": false
      },
      {
        "targets": [7],
        "visible": false
      }
    ]});

  // Because the table saves state, we have to check/uncheck modal inputs based on what
  // columns are visible
  volunteers_table.columns().every(function (index) {
    var column_visible = this.visible();

    if(column_visible)
      $('#visibleColumns input[data-column="' + index + '"]').prop('checked', true);
    else
      $('#visibleColumns input[data-column="' + index + '"]').prop('checked', false)
  })

  $('table#casa_cases').DataTable({"searching": false});
  $('table#case_contacts').DataTable({"searching": false, "order": [[0, "desc" ]]});

  $('.volunteer-filters input[type="checkbox"]').on('click', function() {
    volunteers_table.draw();
  })

  $('input.toggle-visibility').on( 'click', function (e) {
    // Get the column API object and toggle the visibility
    var column = volunteers_table.column($(this).attr('data-column'));
    column.visible(!column.visible());
    volunteers_table.columns.adjust().draw();
  });
});
