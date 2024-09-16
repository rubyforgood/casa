import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="case-contact-form"
export default class extends Controller {
  static targets = [
    'expenseAmount',
    'expenseDescribe',
    'milesDriven',
    'volunteerAddress',
    'reimbursementForm',
    'wantDrivingReimbursement'
  ]

  connect () {
    this.setReimbursementFormVisibility()
  }

  clearExpenses = () => {
    this.expenseDescribeTargets.forEach(el => (el.value = ''))
    this.expenseAmountTargets.forEach(el => (el.value = ''))
  }

  clearMileage = () => {
    this.milesDrivenTarget.value = 0
    this.volunteerAddressTarget.value = ''
  }

  setReimbursementFormVisibility = () => {
    if (this.wantDrivingReimbursementTarget.checked) {
      this.reimbursementFormTarget.classList.remove('d-none')
    } else {
      this.clearExpenses()
      this.clearMileage()
      this.reimbursementFormTarget.classList.add('d-none')
    }
  }
}
