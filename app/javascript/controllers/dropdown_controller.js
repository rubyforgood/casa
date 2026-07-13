import { Controller } from '@hotwired/stimulus'

// Enhances a native <details> disclosure used as a menu: closes it on an outside
// click and on Escape (returning focus to the summary). Opening/closing is still
// the browser's native <details> toggle, so this is progressive enhancement —
// the menu works without JS.
export default class extends Controller {
  connect () {
    this.closeOnOutsideClick = this.closeOnOutsideClick.bind(this)
    this.closeOnEscape = this.closeOnEscape.bind(this)
    document.addEventListener('click', this.closeOnOutsideClick)
    this.element.addEventListener('keydown', this.closeOnEscape)
  }

  disconnect () {
    document.removeEventListener('click', this.closeOnOutsideClick)
    this.element.removeEventListener('keydown', this.closeOnEscape)
  }

  closeOnOutsideClick (event) {
    if (this.element.open && !this.element.contains(event.target)) {
      this.element.open = false
    }
  }

  closeOnEscape (event) {
    if (event.key === 'Escape' && this.element.open) {
      this.element.open = false
      this.element.querySelector('summary')?.focus()
    }
  }
}
