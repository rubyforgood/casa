$('document').ready(() => {
  // Enable all data tables on dashboard but only filter on volunteers table
  $('.show-volunteer-case-contacts').on('click', function(e) {
    var table_target = $(e.target).data('target');
    $(table_target).toggleClass('collapse');
  })
});
