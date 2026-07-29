import { Controller } from '@hotwired/stimulus'

// Generates a court report (docx) from the case-show modal. It posts the date
// range to the JSON endpoint (Rails wraps the flat body under case_court_report),
// shows a spinner while the docx is built, then opens the download in a new tab.
// The Tailwind + Stimulus replacement for the legacy jQuery handleGenerateReport.
export default class extends Controller {
  static targets = ['form', 'timeZone', 'spinner', 'submit', 'error']

  connect () {
    if (this.hasTimeZoneTarget) {
      this.timeZoneTarget.value = Intl.DateTimeFormat().resolvedOptions().timeZone
    }
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
