import { Controller } from '@hotwired/stimulus'

// Copy all court orders from a sibling case into the current one. The Copy button is always
// enabled; clicking it with no case selected shows an inline error, otherwise it opens the
// design-system <dialog> (the `modal` controller centers it) to confirm, then PATCHes
// copy_court_orders and reloads so the copied orders and the flash appear. casa_app only: the
// Bootstrap court-date pages keep the legacy casa_case.js SweetAlert flow.
export default class extends Controller {
  static targets = ['select', 'dialog', 'caseNumber', 'error']
  static values = { casaCaseId: String }

  open () {
    if (this.selectTarget.value === '') {
      if (this.hasErrorTarget) this.errorTarget.classList.remove('hidden')
      this.selectTarget.focus()
      return
    }
    this.clearError()
    this.caseNumberTarget.textContent = this.selectTarget.value
    this.dialogTarget.showModal()
  }

  clearError () {
    if (this.hasErrorTarget) this.errorTarget.classList.add('hidden')
  }

  async confirm () {
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
