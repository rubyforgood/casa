// class="collapse" aria-labelledby="headingOne" data-bs-parent="#accordionTwilio"

// const TWILIO_PHONE_NUMBER = '#casa_org_twilio_phone_number'

function hello () {
  console.log('hello')
  if ($('.accordionTwilio').is(':checked')) {
    console.log('checked')
    addCheckedAttr($('#casa_org_twilio_phone_number'))
    addCheckedAttr($('#casa_org_twilio_account_sid'))
    addCheckedAttr($('#casa_org_twilio_api_key_sid'))
    addCheckedAttr($('#casa_org_twilio_api_key_secret'))
  } else {
    console.log('unchecked')
    removeCheckedAttr($('#casa_org_twilio_phone_number'))
    removeCheckedAttr($('#casa_org_twilio_account_sid'))
    removeCheckedAttr($('#casa_org_twilio_api_key_sid'))
    removeCheckedAttr($('#casa_org_twilio_api_key_secret'))
  }
}

function addCheckedAttr (el) {
  el.attr('required', true)
  el.setAttribute('aria-disabled', false)
  el.removeAttr('disabled')
}

function removeCheckedAttr (el) {
  el.removeAttr('disabled')
  el.attr('disabled', true)
  el.removeAttribute('aria-disabled', true)
}

$('document').ready(() => {
  $('.accordionTwilio').attr('data-bs-toggle', 'collapse')
  $('.accordionTwilio').attr('data-bs-target', '#collapseTwilio')
  $('.accordionTwilio').attr('aria-expanded', 'false')
  console.log('Accordion Twilio', $('.accordionTwilio').val())
  if ($('.accordionTwilio').is(':checked')) {
    $('.accordionTwilio').attr('aria_expanded')
    $('.accordionTwilio').removeClass('collapsed')
    $('#collapseTwilio').addClass('show')
  }
  ($('.accordionTwilio').on('click', hello))
})
