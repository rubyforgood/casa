/* global $ */

function toggleSidebar () {
  const isOpen = $('#sidebar-js').hasClass('sidebar-open')
  if (isOpen) {
    $('#sidebar-js').removeClass('sidebar-open')
  } else {
    $('#sidebar-js').addClass('sidebar-open')
  }
}

$(() => { // JQuery's callback for the DOM loading
  $('#toggle-sidebar-js, #sidebar-js').on('click', toggleSidebar)

  // Show group actions dropdown expanded when any of the child is active
  if ($('#ddmenu_55 li').children('a').hasClass('active')) {
    $('#ddmenu_55').addClass('show')
  } else {
    $('#ddmenu_55').removeClass('show')
  }
})
