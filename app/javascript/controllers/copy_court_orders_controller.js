import { Controller } from '@hotwired/stimulus'

// Copy all court orders from a sibling case into the current one. "Copy from another case" opens a
// design-system <dialog> (the `modal` controller centers it) holding the case picker; confirming with
// nothing chosen shows an inline error inside the dialog, otherwise it PATCHes copy_court_orders and
// reloads so the copied orders and the flash appear. casa_app only: the Bootstrap court-date pages
// keep the legacy casa_case.js SweetAlert flow (it binds `button.copy-court-button` by class, which
// this button deliberately does not carry).
export default class extends Controller {
  static targets = ['select', 'dialog', 'error']
  static values = { casaCaseId: String }

  // The case picker lives inside the dialog now, so opening cannot validate anything -- there is
  // nothing chosen yet. Validation moved to #confirm.
  open () {
    this.clearError()
    this.dialogTarget.showModal()
  }

  clearError () {
    if (this.hasErrorTarget) this.errorTarget.classList.add('hidden')
  }

  async confirm () {
    if (this.selectTarget.value === '') {
      if (this.hasErrorTarget) this.errorTarget.classList.remove('hidden')
      this.selectTarget.focus()
      return
    }

    const token = document.querySelector('meta[name="csrf-token"]')?.content
    const response = await fetch(`/casa_cases/${this.casaCaseIdValue}/copy_court_orders`, {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': token,
        'X-Requested-With': 'XMLHttpRequest',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({ case_number_cp: this.selectTarget.value })
    })

    if (response.ok) {
      window.location.reload()
    } else {
      this.dialogTarget.close()
    }
  }
}
