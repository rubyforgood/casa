import $ from 'jquery'
$('document').ready(() => {
  // inside the app/views/casa_contact/_form, we are trying to only show a field if 'other' is chosen.
  $("#contact_type").change((e) => {
    if (e.target.value === 'other') {
      $(".other-contact-type").removeAttr('hidden')
      $(".other-contact-type input").attr('required', 'required')
    } else {
      $(".other-contact-type").attr('hidden', true)
      $(".other-contact-type input").removeAttr('required')
    }
  })

})

