import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['icon', 'margin']
  static values = {
    icons: Array
  }

  toggle () {
    this.iconsValue.forEach((icon) => {
      this.iconTarget.classList.toggle(icon)
    })
    this.marginTarget.classList.toggle('mb-3')
  }
}
