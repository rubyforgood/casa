/* global window */
/* global $ */

import { escape } from 'lodash'
import Swal from 'sweetalert2'

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

$(() => { // JQuery's callback for the DOM loading
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

  function validateNoteContent (e) {
    const noteContent = $('#case_contact_notes').val()
    if (noteContent) {
      e.preventDefault()
      $('#confirm-submit').modal('show')
      $('#note-content').html(escape(noteContent))
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

  $('[data-toggle="tooltip"]').tooltip()
  $('.followup-button').on('click', displayFollowupAlert)

  if (/\/case_contacts\/*.*\?.*success=true/.test(window.location.href)) {
    $('#thank_you').modal()
  }
})

export {
  convertDateToSystemTimeZone
}
