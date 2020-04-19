$('document').ready(() => {
  $.fn.dataTable.ext.search.push(
    function( settings, data, dataIndex ) {
      var supervisor_array = [""];
      var status_array = [];

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

      var supervisor = data[1];
      var status = data[2];

      if(supervisor_array.includes(supervisor) && status_array.includes(status)) {
        return true;
      }

      return false;
    }
  );

  var table = $('#volunteers').DataTable();

  $('.volunteer-filters input[type="checkbox"]').on('click', function() {
    table.draw();
  })
});
