/* global $ */
function toggleSidebar () {
  const isOpen = $('#sidebar-js').hasClass('sidebar-open')
  if (isOpen) {
    $('#sidebar-js').removeClass('sidebar-open')
  } else {
    $('#sidebar-js').addClass('sidebar-open')
  }
}

$('document').ready(() => {
  $('#toggle-sidebar-js, #sidebar-js').on('click', toggleSidebar)
})
