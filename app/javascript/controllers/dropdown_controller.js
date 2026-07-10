import { Controller } from '@hotwired/stimulus'

// Popover / dropdown menu: toggles a panel and closes it on outside click or Escape.
// (The disclosure controller is for inline panels that should stay open; this one is
// for overlay menus like the case filters and column picker.)
export default class extends Controller {
  static targets = ['panel', 'trigger']

  toggle () {
    this.panelTarget.classList.contains('hidden') ? this.open() : this.close()
  }

  open () {
    this.panelTarget.classList.remove('hidden')
    if (this.hasTriggerTarget) this.triggerTarget.setAttribute('aria-expanded', 'true')
    this.outsideClick = (event) => { if (!this.element.contains(event.target)) this.close() }
    this.onEscape = (event) => { if (event.key === 'Escape') this.close() }
    document.addEventListener('click', this.outsideClick)
    document.addEventListener('keydown', this.onEscape)
  }

  close () {
    this.panelTarget.classList.add('hidden')
    if (this.hasTriggerTarget) this.triggerTarget.setAttribute('aria-expanded', 'false')
    document.removeEventListener('click', this.outsideClick)
    document.removeEventListener('keydown', this.onEscape)
  }

  disconnect () {
    document.removeEventListener('click', this.outsideClick)
    document.removeEventListener('keydown', this.onEscape)
  }
}
