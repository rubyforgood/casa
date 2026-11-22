import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="report-submit"
// Disables the export button, swaps its label to the `data-disable-with` text,
// submits the enclosing form natively (bypassing Turbo for streaming CSV downloads),
// and re-enables the button after 3 seconds so subsequent downloads work without a page reload.
export default class extends Controller {
  static values = {
    timeout: { type: Number, default: 3000 }
  }

  disconnect () {
    this.clearTimer()
  }

  submit (event) {
    if (this.element.disabled) return

    const form = this.element.form || this.element.closest('form')
    if (!form) return

    event.preventDefault()

    this.originalContent = this.element.innerHTML
    this.element.disabled = true
    if (this.element.dataset.disableWith) {
      this.element.innerHTML = this.element.dataset.disableWith
    }

    form.submit()

    this.clearTimer()
    this.timer = setTimeout(() => {
      this.reset()
    }, this.timeoutValue)
  }

  reset () {
    this.element.disabled = false
    if (this.originalContent !== undefined) {
      this.element.innerHTML = this.originalContent
    }
    this.clearTimer()
  }

  clearTimer () {
    if (this.timer) {
      clearTimeout(this.timer)
      this.timer = null
    }
  }
}
