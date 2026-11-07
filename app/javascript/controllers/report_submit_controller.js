import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  submit (event) {
    event.preventDefault()
    if (this.element.disabled) return

    this.originalHTML = this.element.innerHTML
    this.element.disabled = true
    this.element.innerHTML = this.element.dataset.disableWith
    // A native submit starts the CSV download without Turbo handling the response.
    this.element.form.submit()

    // Downloads do not reload the page, so restore the button for another export.
    this.timer = setTimeout(() => this.restore(), 3000)
  }

  disconnect () {
    clearTimeout(this.timer)
    this.restore()
  }

  restore () {
    if (this.originalHTML === undefined) return

    this.element.disabled = false
    this.element.innerHTML = this.originalHTML
    this.originalHTML = undefined
  }
}
