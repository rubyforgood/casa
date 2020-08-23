/* global alert */
window.onload = function () {
  const milesDriven = document.getElementById('case_contact_miles_driven')
  const durationHours = document.getElementById('case-contact-duration-hours')
  const durationHourDisplay = document.getElementById('casa-contact-duration-hours-display')
  const durationMinutes = document.getElementById('case-contact-duration-minutes')
  const durationMinuteDisplay = document.getElementById('casa-contact-duration-minutes-display')
  const caseContactSubmit = document.getElementById('case-contact-submit')
  const contactTypeForm = document.getElementById('contact-type-form')

  milesDriven.onchange = function () {
    const contactMedium = document.getElementById('case_contact_medium_type').value || '(contact medium not set)'
    const contactMediumInPerson = `${contactMedium}` === 'in-person'
    if (milesDriven.value > 0 && !contactMediumInPerson) {
      alert(`Just checking: you drove ${milesDriven.value} miles for a ${contactMedium} contact?`)
    }
  }
  durationHours.onchange = updateHours()
  durationHourDisplay.onchange = updateHours()
  durationHourDisplay.onkeyup = updateHours()

  durationMinutes.onchange = updateMinutes()
  durationMinuteDisplay.onchange = updateMinutes()
  durationMinuteDisplay.onkeyup = updateMinutes()

  function updateMinutes () {
    if (durationMinuteDisplay.value !== durationMinutes.value) {
      durationMinutes.value = durationMinuteDisplay.value
    }
  }

  function updateHours () {
    if (durationHourDisplay.value !== durationHours.value) {
      durationHourDisplay.value = durationHours.value
    }
  }

  function validateContactType () {
    const childElements = Array.from(contactTypeForm.children)
    const isAtLeastOneChecked = childElements.filter(x => {
      return x.querySelector('input') && x.querySelector('input').checked
    }).length
    if (!isAtLeastOneChecked) {
      childElements[2].querySelector('input').setAttribute('required', true)
    } else {
      childElements[2].querySelector('input').removeAttribute('required')
    }
  }

  function validateDuration () {
    const msg = 'Please enter a minimum duration of 15 minutes (even if you spent less time than this).'
    const fifteenMinutes = 15
    const totalMinutes = durationMinutes.value + durationHours.value * 60

    if (totalMinutes < fifteenMinutes) {
      durationMinutes.setCustomValidity(msg)
    } else {
      durationMinutes.setCustomValidity('')
    }
  }

  caseContactSubmit.onclick = function () {
    validateContactType()
    validateDuration()
  }
}
