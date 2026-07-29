import { Controller } from '@hotwired/stimulus'

// Toggles the visibility of a target (e.g. the "this replaces your active banner"
// warning on the banner form) when a checkbox is clicked. The initial hidden state is
// server-rendered; each click flips it. Connects to data-controller="reveal".
export default class extends Controller {
  static targets = ['item']
  static classes = ['hidden']

  toggle () {
    this.itemTargets.forEach((item) => item.classList.toggle(this.hiddenClass))
  }
}
