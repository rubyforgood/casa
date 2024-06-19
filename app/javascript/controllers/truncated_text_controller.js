import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="truncated-text"
export default class extends Controller {
  static targets = ['moreButton', 'hideButton', 'text']

  toggle () {
    this.hideButtonTarget.classList.toggle('d-none')
    this.moreButtonTarget.classList.toggle('d-none')
    this.textTarget.classList.toggle('line-clamp-1')
  }
}
