import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['title', 'list', 'link']

  connect () {
    this.toggleShow()
  }

  // Expands list if a link is active
  toggleShow () {
    this.linkTargets.forEach((link) => {
      if (link.classList.contains('active')) {
        this.titleTarget.classList.remove('collapsed')
        this.listTarget.classList.add('show')
      }
    })
  }
}
