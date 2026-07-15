import { Controller } from '@hotwired/stimulus'

// Copy all court orders from a sibling case into the current one. The button is enabled
// only once a case is picked; clicking it opens the design-system <dialog> (the `modal`
// controller centers it) to confirm, then PATCHes copy_court_orders and reloads so the
// copied orders and the flash appear. casa_app only: the Bootstrap court-date pages keep
// the legacy casa_case.js SweetAlert flow.
export default class extends Controller {
  static targets = ['select', 'button', 'dialog', 'caseNumber']
  static values = { casaCaseId: String }

  connect () {
    this.toggle()
  }

  toggle () {
    this.buttonTarget.disabled = this.selectTarget.value === ''
  }

  open () {
    this.caseNumberTarget.textContent = this.selectTarget.value
    this.dialogTarget.showModal()
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
