import { Controller } from '@hotwired/stimulus'

// Generates a court report (docx) from the case-show modal. It posts the date
// range to the JSON endpoint (Rails wraps the flat body under case_court_report),
// shows a spinner while the docx is built, then opens the download in a new tab.
// The Tailwind + Stimulus replacement for the legacy jQuery handleGenerateReport.

// Today as YYYY-MM-DD in the BROWSER's zone. toISOString() on its own is UTC, which is the skew this
// works around, so shift by the local offset first.
const localToday = () => {
  const now = new Date()
  return new Date(now.getTime() - now.getTimezoneOffset() * 60000).toISOString().slice(0, 10)
}

export default class extends Controller {
  static targets = ['form', 'timeZone', 'spinner', 'submit', 'error', 'startDate', 'endDate']

  connect () {
    if (this.hasTimeZoneTarget) {
      this.timeZoneTarget.value = Intl.DateTimeFormat().resolvedOptions().timeZone
    }
    this.fillEndDate()
  }

  // "Ending at" is today in the USER's zone. The server renders Date.current and the app runs in UTC
  // (config.time_zone is unset), so the field read as TOMORROW for anyone west of UTC in the evening
  // (after 8pm in New York) and as YESTERDAY for anyone east of it in the morning -- and yesterday
  // silently cuts today's contacts out of the report. The generator parses both dates in the
  // time_zone this form already sends, so the browser's date is the right one to submit.
  fillEndDate () {
    if (this.hasEndDateTarget) this.endDateTarget.value = localToday()
  }

  // Autofills "Starting from" with the picked case's own default (its last hearing, or when the case
  // was opened in CASA) -- carried on each <option> as data-start-date, since the default is per-case
  // and the case is chosen in this modal. Read off the native <select>, which TomSelect keeps in sync,
  // rather than TomSelect's internal option data.
  caseChanged (event) {
    if (!this.hasStartDateTarget) return

    const option = event.target.selectedOptions[0]
    const startDate = option && option.dataset.startDate
    if (startDate) this.startDateTarget.value = startDate
    // Both ends stay filled: refill "Ending at" if it was cleared.
    if (this.hasEndDateTarget && !this.endDateTarget.value) this.fillEndDate()
  }

  async generate (event) {
    event.preventDefault()
    const form = this.formTarget
    if (!form.reportValidity()) return

    this.setBusy(true)
    try {
      const response = await window.fetch(form.action, {
        method: 'POST',
        headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
        body: JSON.stringify(Object.fromEntries(new window.FormData(form)))
      })
      const data = await response.json()
      if (data.status !== 'ok') {
        this.showError(data.error_messages)
        return
      }
      window.open(data.link, '_blank')
    } catch (error) {
      this.showError('Something went wrong generating the report. Please try again.')
    } finally {
      this.setBusy(false)
    }
  }

  setBusy (busy) {
    if (this.hasSpinnerTarget) this.spinnerTarget.classList.toggle('hidden', !busy)
    if (this.hasSubmitTarget) this.submitTarget.disabled = busy
  }

  showError (html) {
    if (this.hasErrorTarget) {
      this.errorTarget.innerHTML = html
      this.errorTarget.classList.remove('hidden')
    }
  }
}
