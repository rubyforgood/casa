import { Controller } from '@hotwired/stimulus'

// Enhances a native <details> disclosure used as a menu:
// - only one dropdown is open at a time (opening one closes the others),
// - it closes on an outside click and on Escape (returning focus to the summary).
// Opening/closing is still the browser's native <details> toggle, so this is
// progressive enhancement — the menu works without JS.
export default class extends Controller {
  connect () {
    this.closeSiblings = this.closeSiblings.bind(this)
    this.closeOnOutsideClick = this.closeOnOutsideClick.bind(this)
    this.closeOnEscape = this.closeOnEscape.bind(this)
    this.element.addEventListener('toggle', this.closeSiblings)
    document.addEventListener('click', this.closeOnOutsideClick)
    this.element.addEventListener('keydown', this.closeOnEscape)
  }

  disconnect () {
    this.element.removeEventListener('toggle', this.closeSiblings)
    document.removeEventListener('click', this.closeOnOutsideClick)
    this.element.removeEventListener('keydown', this.closeOnEscape)
  }

  // When this menu opens, close every other open dropdown so only one is open.
  closeSiblings () {
    if (!this.element.open) return
    document.querySelectorAll('details[data-controller~="dropdown"][open]').forEach((other) => {
      if (other !== this.element) other.open = false
    })
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
