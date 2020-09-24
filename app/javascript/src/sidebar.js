/* global $ */
$('document').ready(() => {
  $('#toggle-sidebar-js').on("click", function() {
    const isOpen = $( "#sidebar-js" ).hasClass( "sidebar-open" );
    if (isOpen) {
      $('#sidebar-js').removeClass('sidebar-open')
    } else {
      $('#sidebar-js').addClass('sidebar-open')
    }
  });

  $('#sidebar-js').on("click", function() {
    const isOpen = $( "#sidebar-js" ).hasClass( "sidebar-open" );
    if (isOpen) {
      $('#sidebar-js').removeClass('sidebar-open')
    } else {
      $('#sidebar-js').addClass('sidebar-open')
    }
  });
})
