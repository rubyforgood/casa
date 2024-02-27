import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['submitButton', 'input']
  static values = {
    unallowed: { type: Array }
  }

  static classes = ['disabled', 'enabled']

  validate () {
    let invalid = false
    this.inputTargets.forEach(input => {
      if (this.unallowedValue.includes(input.value)) {
        invalid = true
      }
    })

    if (invalid) {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.classList.add(this.disabledClass)
      this.submitButtonTarget.classList.remove(...this.enabledClasses)
    } else {
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.classList.remove(this.disabledClass)
      this.submitButtonTarget.classList.add(...this.enabledClasses)
    }
  }
}
