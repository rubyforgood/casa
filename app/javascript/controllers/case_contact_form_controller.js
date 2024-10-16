import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="case-contact-form"
export default class extends Controller {
  static targets = [
    'expenseDestroy',
    'milesDriven',
    'volunteerAddress',
    'reimbursementForm',
    'wantDrivingReimbursement'
  ]

  connect () {
    this.setReimbursementFormVisibility()
  }

  clearExpenses = () => {
    // mark as _destroy: true. autosave has already created the records.
    // if autosaved again, nested form controller will remove destroy: true items
    // if the form is submitted, expense will be destroyed.
    this.expenseDestroyTargets.forEach(el => (el.value = '1'))
  }

  clearMileage = () => {
    this.milesDrivenTarget.value = 0
    this.volunteerAddressTarget.value = ''
  }

  setReimbursementFormVisibility = () => {
    if (this.wantDrivingReimbursementTarget.checked) {
      this.reimbursementFormTarget.classList.remove('d-none')
      this.expenseDestroyTargets.forEach(el => (el.value = '0'))
    } else {
      this.clearExpenses()
      this.clearMileage()
      this.reimbursementFormTarget.classList.add('d-none')
    }
  }
}
