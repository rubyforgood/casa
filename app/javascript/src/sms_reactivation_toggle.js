$(() => { // JQuery's callback for the DOM loading
  if ($('#twilio_disabled').length) {
    $('#twilio_disabled').removeClass('main-btn danger-btn-outline btn-hover btn-sm my-1')
    $('#twilio_disabled').addClass('main-btn deactive-btn btn-sm my-1')
    $('#twilio_tooltip').attr('data-bs-toggle', 'tooltip')
    $('#twilio_tooltip').attr('data-bs-placement', 'bottom')
    $('#twilio_tooltip').attr('data-turbo', 'false')
    $('#twilio_tooltip').attr('title', "Twilio is not enabled for this user's CASA org")

    $('#twilio_disabled').on('click', function (event) {
      event.preventDefault()
      console.log('tooltip?')
    })
  }
})
