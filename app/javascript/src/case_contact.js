/* global alert */
/* global window */
/* global $ */

import Swal from 'sweetalert2'

window.onload = function () {
  const milesDriven = document.getElementById('case_contact_miles_driven')
  if (!milesDriven) return

  const durationHours = document.getElementById('case-contact-duration-hours-display')
  const durationMinutes = document.getElementById('case-contact-duration-minutes-display')
  const caseOccurredAt = document.getElementById('case_contact_occurred_at')
  const caseContactSubmit = document.getElementById('case-contact-submit')
  const volunteerAddressFieldState = (hide) => {
    if (hide) $('.field.volunteer-address').addClass('hide-field')
    else $('.field.volunteer-address').removeClass('hide-field')
    $('.field.volunteer-address input[type=text]').prop('disabled', hide)
    $('.field.volunteer-address input[type=hidden]').prop('disabled', hide)
    $('.field.volunteer-address input[type=text]').prop('required', !hide)
  }

  if ($('.want-driving-reimbursement input.form-check-input[type="radio"][value=true]')[0].checked) {
    volunteerAddressFieldState(false)
  } else {
    volunteerAddressFieldState(true)
  }

  $('.want-driving-reimbursement input.form-check-input[type="radio"]').on('change', function () {
    if (this.value === 'true') {
      volunteerAddressFieldState(false)
    } else if (this.value === 'false') {
      volunteerAddressFieldState(true)
    }
  })

  const timeZoneConvertedDate = enGBDateString(new Date())

  if (enGBDateString(convertDateToSystemTimeZone(caseOccurredAt.value)) === timeZoneConvertedDate) {
    caseOccurredAt.value = timeZoneConvertedDate
  }

  milesDriven.onchange = function () {
    const contactMedium = document.getElementById('case_contact_medium_type').value || '(contact medium not set)'
    const contactMediumInPerson = `${contactMedium}` === 'in-person'
    if (milesDriven.value > 0 && !contactMediumInPerson) {
      alert(`Just checking: you drove ${milesDriven.value} miles for a ${contactMedium} contact?`)
    }
  }

  caseOccurredAt.onchange = function () {
    validateOccurredAt(caseOccurredAt)
  }

  caseOccurredAt.onfocusout = function () {
    validateOccurredAt(caseOccurredAt, 'focusout')
  }

  function validateAtLeastOneChecked (elements) {
    // convert to Array
    const elementsArray = Array.prototype.slice.call(elements)

    const numChecked = elementsArray.filter(x => x.checked).length
    if (numChecked === 0) {
      elementsArray[0].required = true
    } else {
      elementsArray[0].required = false
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

  function validateNoteContent (e) {
    const noteContent = document.getElementById('case_contact_notes').value
    if (noteContent !== '') {
      e.preventDefault()
      $('#confirm-submit').modal('show')
      const escapedNoteContent = noteContent.replace(/&/g, '&amp;')
        .replace(/>/g, '&gt;')
        .replace(/</g, '&lt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&apos;')
      document.getElementById('note-content').innerHTML = escapedNoteContent
    }
  }

  $('#casa-contact-form').submit(function (e) {
    validateNoteContent(e)
  })

  $('#confirm-submit').on('focus', function () {
    document.getElementById('modal-case-contact-submit').disabled = false
  })

  $('#confirm-submit').on('hide.bs.modal', function () {
    caseContactSubmit.disabled = false
  })

  const caseContactSubmitFromModal = document.getElementById('modal-case-contact-submit')
  caseContactSubmitFromModal.onclick = function () {
    $('#casa-contact-form').unbind('submit')
  }

  caseContactSubmit.onclick = function (e) {
    validateAtLeastOneChecked(document.querySelectorAll('.casa-case-id'))
    validateAtLeastOneChecked(document.querySelectorAll('.case-contact-contact-type'))

    validateDuration()
  }
}

function validateOccurredAt (caseOccurredAt, eventType = '') {
  const msg = 'Case Contact Occurrences cannot be in the future.'
  const today = new Date()
  today.setHours(0, 0, 0, 0)

  const caseDate = new Date(caseOccurredAt.value)
  caseDate.setDate(caseDate.getDate())
  caseDate.setHours(0, 0, 0, 0)

  if (caseDate > today) {
    if (eventType !== 'focusout') {
      alert(msg)
    }
    caseOccurredAt.value = enGBDateString(today)
  }
}

function enGBDateString (date) {
  return date.toLocaleDateString('en-GB').split('/').reverse().join('-')
}

function convertDateToSystemTimeZone (date) {
  return new Date((typeof date === 'string' ? new Date(date) : date))
}

async function displayFollowupAlert () {
  const { value: text, isConfirmed } = await fireSwalFollowupAlert()

  if (!isConfirmed) return

  const params = text ? { note: text } : {}
  const caseContactId = this.id.replace('followup-button-', '')

  $.post(
    `/case_contacts/${caseContactId}/followups`,
    params,
    () => window.location.reload()
  )
}

async function fireSwalFollowupAlert () {
  const inputLabel = 'Optional: Add a note about what followup is needed.'

  return await Swal.fire({
    input: 'textarea',
    title: inputLabel,
    inputPlaceholder: 'Type your note here...',
    inputAttributes: { 'aria-label': 'Type your note here' },

    showCancelButton: true,
    showCloseButton: true,

    confirmButtonText: 'Confirm',
    confirmButtonColor: '#dc3545',

    customClass: {
      inputLabel: 'mx-5'
    }
  })
}

function displayHighlightModal (event) {
  event.preventDefault()
  $('#caseContactHighlight').modal('show')
}

$('document').ready(() => {
  console.log("Page is loaded, original firing")
  $('[data-toggle="tooltip"]').tooltip()
  $('.followup-button').on('click', displayFollowupAlert) //this works! why doesnt the thank you modal
  $('#open-highlight-modal').on('click', displayHighlightModal)
  
  if (/\/casa_cases\/*.*\?.*success=true/.test(window.location.href)) {
    $('#thank_you').modal("show")
  }
})

//this doesn't seem to fire at all
/*$(document).on('page:load', function () {
    $console.log("loaded!")
    $('#thank_you').modal("show");
});*/

export {
  validateOccurredAt,
  convertDateToSystemTimeZone
}
