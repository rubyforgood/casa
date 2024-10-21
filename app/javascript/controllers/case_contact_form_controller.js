import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="case-contact-form"
export default class extends Controller {
  static targets = [
    'addTopicButton',
    'contactTopicSelect',
    'expenseDestroy',
    'milesDriven',
    'volunteerAddress',
    'reimbursementForm',
    'wantDrivingReimbursement'
  ]

  connect () {
    this.contactTopicCount = 0
    if (this.hasContactTopicSelectTarget) {
      this.contactTopicCount = (this.contactTopicSelectTargets[0].querySelectorAll('option').length) - 1
      this.onContactTopicSelect()
      this.toggleAddAnotherTopicButton()
    }

    this.setReimbursementFormVisibility()
    document.addEventListener('casa-nested-form:change', (e) => this.onNestedFormChange(e))
  }

  toggleAddAnotherTopicButton () {
    const currentCount = this.contactTopicSelectTargets.length
    if (currentCount < this.contactTopicCount) {
      this.addTopicButtonTarget.disabled = false
    } else {
      this.addTopicButtonTarget.disabled = true
    }
  }

  onNestedFormChange (e) {
    const { modelName } = e.detail
    if (modelName === 'contact_topic_answer') {
      this.onContactTopicSelect()
      this.toggleAddAnotherTopicButton()
    }
  }

  onContactTopicSelect (_e) {
    const selectedValues = this.contactTopicSelectTargets.map(el => el.value)
    this.contactTopicSelectTargets.forEach(el => {
      const options = el.querySelectorAll('option')
      options.forEach(option => {
        if (selectedValues.includes(option.value)) {
          if (option.selected) {
            option.disabled = false
          } else {
            option.disabled = true
          }
        } else {
          option.disabled = false
        }
      })
    })
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
