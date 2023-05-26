function twilioToggle () {
  const phoneNumber = $('#casa_org_twilio_phone_number')
  const accSid = $('#casa_org_twilio_account_sid')
  const keySid = $('#casa_org_twilio_api_key_sid')
  const secret = $('#casa_org_twilio_api_key_secret')

  if ($('.accordionTwilio').is(':checked')) {
    addCheckedAttr(phoneNumber)
    addCheckedAttr(accSid)
    addCheckedAttr(keySid)
    addCheckedAttr(secret)
  } else {
    removeCheckedAttr(phoneNumber)
    removeCheckedAttr(accSid)
    removeCheckedAttr(keySid)
    removeCheckedAttr(secret)
  }
}

function addCheckedAttr (el) {
  el.attr('required', true)
  el.setAttribute('aria-disabled', false)
  el.setAttribute('aria-required', true)
  el.removeAttr('disabled')
}

function removeCheckedAttr (el) {
  el.attr('disabled', true)
  el.setAttribute('aria-required', false)
  el.removeAttribute('aria-disabled', true)
  el.removeAttr('required')
}

$('document').ready(() => {
  $('.accordionTwilio').attr('data-bs-toggle', 'collapse')
  $('.accordionTwilio').attr('data-bs-target', '#collapseTwilio')
  $('.accordionTwilio').attr('aria-expanded', 'false')

  if ($('.accordionTwilio').is(':checked')) {
    $('.accordionTwilio').attr('aria_expanded')
    $('.accordionTwilio').removeClass('collapsed')
    $('#collapseTwilio').addClass('show')
  }

  ($('.accordionTwilio').on('click', twilioToggle))
})
