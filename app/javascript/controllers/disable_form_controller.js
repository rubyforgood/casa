import { Controller } from '@hotwired/stimulus'

// Guards a form submit: if a watched input still holds an unallowed value (e.g. an unselected
// dropdown prompt), block the submit and reveal an inline error + focus the input -- instead of
// leaving a disabled submit button with no explanation.
export default class extends Controller {
  static targets = ['input', 'error']
  static values = { unallowed: { type: Array, default: [] } }

  guard (event) {
    const invalidInput = this.inputTargets.find((input) => this.unallowedValue.includes(input.value))
    if (invalidInput) {
      event.preventDefault()
      event.stopPropagation()
      if (this.hasErrorTarget) this.errorTarget.classList.remove('hidden')
      invalidInput.focus()
    }
  }

  clearError () {
    const invalidInput = this.inputTargets.find((input) => this.unallowedValue.includes(input.value))
    if (!invalidInput && this.hasErrorTarget) this.errorTarget.classList.add('hidden')
  }
}
