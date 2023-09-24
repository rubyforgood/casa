/* eslint-env jquery */

const COURT_DATE_TOGGLE_CLASS = 'toggle-court-date-input'
const COURT_DATE_INPUT_ID = 'casa_case_court_dates_attributes_0_date'

$(() => { // JQuery's callback for the DOM loading
  const courtDateToggle = $(`.${COURT_DATE_TOGGLE_CLASS}`)[0]
  const courtDateInput = $(`#${COURT_DATE_INPUT_ID}`)[0]

  courtDateToggle?.addEventListener('change', () => {
    courtDateInput.hidden = courtDateToggle.checked
  })
})
