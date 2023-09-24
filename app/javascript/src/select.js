/* global $ */

$(() => { // JQuery's callback for the DOM loading
  $('.select2').select2(
    {
      theme: 'bootstrap-5',
      width: $(this).data('width') ? $(this).data('width') : $(this).hasClass('w-100') ? '100%' : 'style',
      placeholder: $(this).data('placeholder')
    }
  )
})
