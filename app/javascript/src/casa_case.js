/* eslint-env jquery */
/* global FormData */
/* global DOMParser */
/* global spinner */
/* global $ */

import Swal from 'sweetalert2'

function copyOrdersFromCaseWithConfirmation () {
  const id = $(this).next().val()
  const caseNumber = $('select.siblings-casa-cases').find(':selected').text()
  const text = `Are you sure you want to copy all orders from case #${caseNumber}?`
  Swal.fire({
    icon: 'warning',
    title: `Copy all orders from case #${caseNumber}?`,
    text,
    showCloseButton: true,
    showCancelButton: true,
    focusConfirm: false,

    confirmButtonColor: '#d33',
    cancelButtonColor: '#39c',

    confirmButtonText: 'Copy',
    cancelButtonText: 'Cancel'
  }).then((result) => {
    if (result.isConfirmed) {
      copyOrdersFromCaseAction(id, caseNumber)
    }
  })
}

function copyOrdersFromCaseAction (id, caseNumber) {
  $.ajax({
    url: `/casa_cases/${id}/copy_court_orders`,
    method: 'patch',
    data: {
      case_number_cp: caseNumber
    },
    success: () => {
      Swal.fire({
        icon: 'success',
        text: 'Court orders have been copied.',
        showCloseButton: true,
        timer: 2000
      }).then(() => window.location.reload(true))
    },
    error: () => {
      Swal.fire({
        icon: 'error',
        text: 'Something went wrong when attempting to copy court orders.',
        showCloseButton: true
      })
    }
  })
}

function showBtn (el) {
  if (!el) return
  el.classList.remove('d-none')
}

function hideBtn (el) {
  if (!el) return
  el.classList.add('d-none')
}

function disableBtn (el) {
  if (!el) return
  el.disabled = true
  el.classList.add('disabled')
  el.setAttribute('aria-disabled', true)
}

function enableBtn (el) {
  if (!el) return
  el.disabled = false
  el.classList.remove('disabled')
  el.removeAttribute('aria-disabled')
}

function showAlert (html) {
  const alertEl = new DOMParser().parseFromString(html, 'text/html').body.firstElementChild
  const flashContainer = document.querySelector('.header-flash')
  flashContainer && flashContainer.replaceWith(alertEl)
}

function validateForm (formEl, errorEl) {
  if (!formEl) {
    return
  }

  // check html validations, checkValidity returns false if doesn't pass validation
  if (errorEl && !formEl.checkValidity()) {
    errorEl.classList.remove('d-none')
  }
}

function handleGenerateReport (e) {
  e.preventDefault()

  const form = e.currentTarget.form

  const formData = Object.fromEntries(new FormData(form))
  const errorEl = document.querySelector('.select-required-error')
  validateForm(form, errorEl ?? null)
  if (formData.case_number.length === 0) return

  const generateBtn = e.currentTarget
  disableBtn(generateBtn)

  const url = e.currentTarget.form.action
  const options = {
    method: 'POST',
    headers: {
      Accept: 'application/json',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(formData)
  }
  showBtn(spinner)
  hideBtn($('#btnGenerateReport .lni-download')[0])
  window.fetch(url, options)
    .then(response => {
      return response.json()
    })
    .then(data => {
      if (data.status !== 'ok') {
        showAlert(data.error_messages)
        enableBtn(generateBtn)
        hideBtn(spinner)
        return
      }
      hideBtn(spinner)
      showBtn($('#btnGenerateReport .lni-download')[0])
      enableBtn(generateBtn)
      window.open(data.link, '_blank')
    })
    .catch((error) => {
      console.error('Debugging info, error:', error)
    })
}

function clearSelectErrors () {
  const errorEl = document.querySelector('.select-required-error')

  if (!errorEl) return

  errorEl.classList.add('d-none')
}

function handleModalClose () {
  const selectEl = document.querySelector('#case-selection')

  if (!selectEl) return

  clearSelectErrors()
  // this line taken from docs https://select2.org/programmatic-control/add-select-clear-items
  $('#case-selection').val(null).trigger('change')
}

$(() => { // JQuery's callback for the DOM loading
  $('button.copy-court-button').on('click', copyOrdersFromCaseWithConfirmation)

  if ($('button.copy-court-button').length) {
    disableBtn($('button.copy-court-button')[0])
  }

  $('#case-selection').on('change', clearSelectErrors)

  $('select.siblings-casa-cases').on('change', () => {
    if ($('select.siblings-casa-cases').find(':selected').text()) {
      enableBtn($('button.copy-court-button')[0])
    } else {
      disableBtn($('button.copy-court-button')[0])
    }
  })
  // modal id is defined in _generate_docx.html.erb so would like to be able to implement modal close logic in that file
  // but not sure how to
  $('#generate-docx-report-modal').on('hidden.bs.modal', () => handleModalClose())

  $('#btnGenerateReport').on('click', handleGenerateReport)

  if (/\/casa_cases\/.*\?.*success=true/.test(window.location.href)) {
    $('#thank_you').modal()
  }
})

export {
  showBtn,
  hideBtn,
  disableBtn,
  enableBtn,
  showAlert
}
