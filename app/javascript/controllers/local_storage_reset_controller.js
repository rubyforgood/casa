import { Controller } from '@hotwired/stimulus'

// Removes a localStorage key on connect, e.g. discarding a saved case-contact
// draft once the contact has been created (this controller is rendered only on
// the success redirect).
export default class extends Controller {
  static values = { key: String }

  connect () {
    if (this.keyValue) window.localStorage.removeItem(this.keyValue)
  }
}
