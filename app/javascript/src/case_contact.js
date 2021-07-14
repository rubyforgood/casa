import Swal from 'sweetalert2'

/* global alert $ */
window.onload = function () {
  const milesDriven = document.getElementById('case_contact_miles_driven')
  if (!milesDriven) return

  const durationHours = document.getElementById('case-contact-duration-hours')
  const durationHourDisplay = document.getElementById('casa-contact-duration-hours-display')
  const durationMinutes = document.getElementById('case-contact-duration-minutes')
  const durationMinuteDisplay = document.getElementById('casa-contact-duration-minutes-display')
  const caseOccurredAt = document.getElementById('case_contact_occurred_at')
  const caseContactSubmit = document.getElementById('case-contact-submit')

  milesDriven.onchange = function () {
    const contactMedium = document.getElementById('case_contact_medium_type').value || '(contact medium not set)'
    const contactMediumInPerson = `${contactMedium}` === 'in-person'
    if (milesDriven.value > 0 && !contactMediumInPerson) {
      alert(`Just checking: you drove ${milesDriven.value} miles for a ${contactMedium} contact?`)
    }
  }

  caseOccurredAt.onchange = function () {
    validateOccurredAt()
  }
  durationHours.onchange = function () {
    if (durationHourDisplay.value !== durationHours.value) {
      durationHourDisplay.value = durationHours.value
    }
  }
  durationHourDisplay.onchange = function () { updateHours() }
  durationHourDisplay.onkeyup = function () { updateHours() }

  durationMinutes.onchange = function () {
    if (durationMinuteDisplay.value !== durationMinutes.value) {
      durationMinuteDisplay.value = durationMinutes.value
    }
  }
  durationMinuteDisplay.onchange = function () { updateMinutes() }
  durationMinuteDisplay.onkeyup = function () { updateMinutes() }

  function updateMinutes () {
    if (durationMinuteDisplay.value !== durationMinutes.value) {
      durationMinutes.value = durationMinuteDisplay.value
    }
  }

  function updateHours () {
    if (durationHourDisplay.value !== durationHours.value) {
      durationHours.value = durationHourDisplay.value
    }
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

  function validateOccurredAt () {
    const msg = 'Case Contact Occurrences cannot be in the future.'
    const today = new Date()
    today.setHours(0, 0, 0, 0)

    const caseDate = new Date(caseOccurredAt.value)
    caseDate.setDate(caseDate.getDate())
    caseDate.setHours(0, 0, 0, 0)

    if (caseDate > today) {
      alert(msg)
    }
  }

  function validateNoteContent (e) {
    const noteContent = document.getElementById('case_contact_notes').value
    if (noteContent !== '') {
      e.preventDefault()
      $('#confirm-submit').modal('show')
      document.getElementById('note-content').innerHTML =
        noteContent.replace(/"/g, "\"")   // Escape meta-characters for CodeQL security
                   .replace(/'/g, "\'")
                   .replace(/</g, "\<")
                   .replace(/>/g, "\>");
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
    inputLabel: inputLabel,
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

$('document').ready(() => {
  $('[data-toggle="tooltip"]').tooltip()
  $('.followup-button').on('click', displayFollowupAlert)
})
