/* global DOMParser */

// Button/alert helpers shared by a few src/ scripts (password_confirmation,
// require_communication_preference) and the Jest suite.
//
// The court-report and copy-court-orders code that used to live here is gone: both are Stimulus
// controllers now (court_report / copy_court_orders), and the jQuery left behind was not merely dead.
// `$('#btnGenerateReport').on('click', handleGenerateReport)` still bound, so one click on "Generate
// report" fired BOTH handlers -- measured: two POSTs to /case_court_reports/generate and two download
// tabs per click. The rest of that DOM-ready block targeted markup the migration removed
// (`button.copy-court-button`, `select.siblings-casa-cases`, `.select-required-error`) and a
// `hidden.bs.modal` event that no Bootstrap modal fires any more.

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

export {
  disableBtn,
  enableBtn,
  showAlert
}
