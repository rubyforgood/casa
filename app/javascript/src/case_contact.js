/* global alert */
/* global window */
/* global $ */

import Swal from 'sweetalert2'

function validateOccurredAt (caseOccurredAt, eventType = '') {
  const msg = 'Case Contact Occurrences cannot be in the future.'
  const today = new Date()
  today.setHours(0, 0, 0, 0)

  const caseDate = new Date(caseOccurredAt.val())
  caseDate.setDate(caseDate.getDate())
  caseDate.setHours(0, 0, 0, 0)

  if (caseDate > today) {
    if (eventType !== 'focusout') {
      alert(msg)
    }
    caseOccurredAt.val(enGBDateString(today))
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

$(() => { // JQuery's callback for the DOM loading
  const milesDriven = $('#case_contact_miles_driven')
  const durationHoursElement = $('#case-contact-duration-hours-display')
  const durationMinutes = $('#case-contact-duration-minutes-display')
  const caseOccurredAt = $('#case_contact_occurred_at')
  const caseContactSubmit = $('#case-contact-submit')
  const volunteerAddressFieldState = (hide) => {
    if (hide) $('.field.volunteer-address').addClass('hide-field')
    else $('.field.volunteer-address').removeClass('hide-field')
    $('.field.volunteer-address input[type=text]').prop('disabled', hide)
    $('.field.volunteer-address input[type=hidden]').prop('disabled', hide)
    $('.field.volunteer-address input[type=text]').prop('required', !hide)
  }

  if ($('.want-driving-reimbursement input.form-check-input[type="radio"][value=true]').prop('checked')) {
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

  if (enGBDateString(convertDateToSystemTimeZone(caseOccurredAt.val())) === timeZoneConvertedDate) {
    caseOccurredAt.val(timeZoneConvertedDate)
  }

  milesDriven.on('change', () => {
    const contactMedium = $('input[name="case_contact[medium_type]"]:checked').val() || '(contact medium not set)'
    const contactMediumInPerson = `${contactMedium}` === 'in-person'
    const milesDrivenCount = milesDriven.val()

    if (milesDrivenCount > 0 && !contactMediumInPerson) {
      alert(`Just checking: you drove ${milesDrivenCount} miles for a ${contactMedium} contact?`)
    }
  })

  caseOccurredAt.on('change', () => {
    validateOccurredAt(caseOccurredAt)
  })

  caseOccurredAt.on('focusout', () => {
    validateOccurredAt(caseOccurredAt, 'focusout')
  })

  function validateDuration () {
    const msg = 'Please enter a minimum duration of 15 minutes (even if you spent less time than this).'
    const fifteenMinutes = 15
    const totalMinutes = durationMinutes.val() + durationHoursElement.val() * 60
    const durationMinutesDOMElement = durationMinutes.get(0)

    if (totalMinutes < fifteenMinutes) {
      durationMinutesDOMElement.setCustomValidity(msg)
    } else {
      durationMinutesDOMElement.setCustomValidity('')
    }

    durationMinutesDOMElement.reportValidity()
  }

  function validateNoteContent (e) {
    const noteContent = $('#case_contact_notes').val()
    if (noteContent) {
      e.preventDefault()
      $('#confirm-submit').modal('show')
      const escapedNoteContent = noteContent.replace(/&/g, '&amp;')
        .replace(/>/g, '&gt;')
        .replace(/</g, '&lt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&apos;')
      $('#note-content').html(escapedNoteContent)
    }
  }

  $('#casa-contact-form').on('submit', function (e) {
    validateNoteContent(e)
  })

  $('#confirm-submit').on('focus', function () {
    $('#modal-case-contact-submit').prop('disabled', false)
  })

  $('#confirm-submit').on('hide.bs.modal', function () {
    caseContactSubmit.prop('disabled', false)
  })

  const caseContactSubmitFormModal = $('#modal-case-contact-submit')
  caseContactSubmitFormModal.on('click', () => {
    $('#casa-contact-form').off('submit')
  })

  caseContactSubmit.on('click', function () {
    validateDuration()
  })

  $('[data-toggle="tooltip"]').tooltip()
  $('.followup-button').on('click', displayFollowupAlert)
  $('#open-highlight-modal').on('click', displayHighlightModal)

  if (/\/case_contacts\/*.*\?.*success=true/.test(window.location.href)) {
    $('#thank_you').modal()
  }
})

export {
  validateOccurredAt,
  convertDateToSystemTimeZone
}
