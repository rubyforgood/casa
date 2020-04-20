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

      var supervisor = data[1];
      var status = data[2];
      var assigned_to_transition_youth = data[3];

      if(supervisor_array.includes(supervisor) &&
        status_array.includes(status) &&
        assigned_to_transition_youth_array.includes(assigned_to_transition_youth)) {
        return true;
      }

      return false;
    }
  );

  // Enable all data tables on dashboard but only filter on volunteers table
  var volunteers_table = $('table#volunteers').DataTable();
  $('table#casa_cases').DataTable({"searching": false});
  $('table#case_contacts').DataTable({"searching": false});

  $('.volunteer-filters input[type="checkbox"]').on('click', function() {
    volunteers_table.draw();
  })
});
