import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['icon']

  toggle () {
    this.iconTarget.classList.toggle('lni-chevron-up')
    this.iconTarget.classList.toggle('lni-chevron-down')
  }
}
