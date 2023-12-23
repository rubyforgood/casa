import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['icon']
  static values = {
    icons: Array
  }

  toggle () {
    this.iconsValue.forEach((icon) => {
      this.iconTarget.classList.toggle(icon)
    })
  }
}
