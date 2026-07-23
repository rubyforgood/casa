import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="truncated-text"
export default class extends Controller {
  static targets = ['moreButton', 'hideButton', 'text']

  toggle () {
    this.hideButtonTarget.classList.toggle('hidden')
    this.moreButtonTarget.classList.toggle('hidden')
    this.textTarget.classList.toggle('line-clamp-1')
  }
}
